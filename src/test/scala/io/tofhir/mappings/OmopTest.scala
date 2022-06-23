package io.tofhir.mappings

import akka.actor.ActorSystem
import akka.http.scaladsl.model.StatusCodes
import com.typesafe.scalalogging.Logger
import io.onfhir.api.util.FHIRUtil
import io.onfhir.client.OnFhirNetworkClient
import io.onfhir.tofhir.config.MappingErrorHandling
import io.onfhir.tofhir.engine._
import io.onfhir.tofhir.model.{FhirMappingTask, FhirRepositorySinkSettings, SqlSource, SqlSourceSettings}
import io.onfhir.tofhir.util.FhirMappingUtility
import io.onfhir.util.JsonFormatter.formats
import org.json4s.JsonAST.JObject
import org.scalatest.BeforeAndAfterAll

import java.nio.file.Paths
import java.sql.{Connection, DriverManager, Statement}
import java.time.OffsetDateTime
import java.util.concurrent.TimeUnit
import scala.concurrent.Await
import scala.concurrent.duration.FiniteDuration
import scala.io.{BufferedSource, Source}
import scala.util.{Failure, Success, Try, Using}

class OmopTest extends TestSpec with BeforeAndAfterAll  {

  val logger: Logger = Logger(this.getClass)

  val DATABASE_URL = "jdbc:h2:mem:inputDb;MODE=PostgreSQL;DB_CLOSE_DELAY=-1;DATABASE_TO_UPPER=FALSE"

  override protected def beforeAll(): Unit = {
    super.beforeAll()
    val sql = readFileContent("/sql/omop-populate.sql")
    runSQL(sql)
  }

  override protected def afterAll(): Unit = {
    val sql = readFileContent("/sql/omop-drop.sql")
    runSQL(sql)
    super.afterAll()
  }

  private def readFileContent(fileName: String): String = {
    val source: BufferedSource = Source.fromInputStream(getClass.getResourceAsStream(fileName))
    try source.mkString finally source.close()
  }

  private def runSQL(sql: String): Boolean = {
    Using.Manager { use =>
      val con: Connection = use(DriverManager.getConnection(DATABASE_URL))
      val stm: Statement = use(con.createStatement)
      stm.execute(sql)
    } match {
      case Success(value) => value
      case Failure(e)     => throw e
    }
  }

  val mappingRepository: IFhirMappingRepository = new FhirMappingFolderRepository(Paths.get("mappings/omop").toAbsolutePath.toUri)

  val contextLoader: IMappingContextLoader = new MappingContextLoader(mappingRepository)

  val schemaRepository = new SchemaFolderRepository(Paths.get("schemas").toAbsolutePath.toUri)

  val sqlSourceSettings: SqlSourceSettings = SqlSourceSettings(name = "test-db-source", sourceUri = "https://www.ohdsi.org/data-standardization/the-common-data-model",
    databaseUrl = DATABASE_URL, username = "", password = "")

  val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)

  val fhirSinkSetting: FhirRepositorySinkSettings = FhirRepositorySinkSettings(fhirRepoUrl = "http://localhost:8081/fhir", writeErrorHandling = MappingErrorHandling.CONTINUE)
  implicit val actorSystem: ActorSystem = ActorSystem("OmopTest")
  val onFhirClient: OnFhirNetworkClient = OnFhirNetworkClient.apply(fhirSinkSetting.fhirRepoUrl)

  val fhirServerIsAvailable: Boolean =
    Try(Await.result(onFhirClient.search("Patient").execute(), FiniteDuration(5, TimeUnit.SECONDS)).httpStatus == StatusCodes.OK)
      .getOrElse(false)

  // sql query mappings tasks
  val careSiteMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/care-site-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select cs.care_site_id, cs.care_site_name, c.concept_code, c.vocabulary_id, c.concept_name, l.address_1, l.address_2, l.city, l.state, l.zip " +
        "from care_site cs, location l, concept c " +
        "where cs.location_id = l.location_id and cs.place_of_service_concept_id = c.concept_id"), settings = sqlSourceSettings)))

  val locationMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/location-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select * from location"), settings = sqlSourceSettings)))

  val procedureOccurrenceMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/procedure-occurrence-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select po.procedure_occurrence_id, po.visit_occurrence_id, po.person_id, c.concept_code, c.vocabulary_id, c.concept_name, " +
        "po.procedure_date, po.procedure_datetime, po.provider_id " +
        "from procedure_occurrence po left join concept c on po.procedure_concept_id = c.concept_id"), settings = sqlSourceSettings)))

  val personMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/person-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select p.person_id, p.gender_concept_id, p.provider_id, p.care_site_id, " +
        "FORMATDATETIME(CONCAT(p.year_of_birth, '-', p.month_of_birth, '-', p.day_of_birth), 'yyyy-MM-dd') as birthdate, " +
        "p.birth_datetime,  l.address_1, l.address_2, l.city, l.state, l.zip, " +
        "c.concept_code as race_code, c.vocabulary_id as race_vocab_id, c.concept_name as race_name, " +
        "c2.concept_code as ethnicity_concept_code, c2.vocabulary_id as ethnicity_vocab_id, c2.concept_name as ethnicity_concept_name " +
        "from person p " +
        "left join location l on p.location_id = l.location_id " +
        "left join concept c on p.race_concept_id = c.concept_id " +
        "left join concept c2 on p.ethnicity_concept_id = c2.concept_id"), settings = sqlSourceSettings)))

  val visitOccurrenceMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/visit-occurrence-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select vo.visit_occurrence_id, vo.care_site_id, vo.preceding_visit_occurrence_id, vo.person_id, " +
        "c.concept_code, c.vocabulary_id, c.concept_name, vo.visit_start_date, vo.visit_start_datetime, vo.visit_end_date, vo.visit_end_datetime, vo.provider_id, " +
        "c2.concept_code as admitted_from_concept_code, c2.vocabulary_id as admitted_from_concept_vocab_id, c2.concept_name as admitted_from_concept_name, " +
        "c3.concept_code as discharged_to_concept_code, c3.vocabulary_id as discharged_to_concept_vocab_id, c3.concept_name as discharged_to_concept_name, " +
        "c4.concept_code as v_type_concept_code, c4.vocabulary_id as v_type_concept_vocab_id, c4.concept_name as v_type_concept_name " +
        "from visit_occurrence vo " +
        "left join concept c on vo.visit_concept_id = c.concept_id " +
        "left join concept c2 on vo.admitted_from_concept_id = c2.concept_id " +
        "left join concept c3 on vo.discharged_to_concept_id = c3.concept_id " +
        "left join concept c4 on vo.visit_type_concept_id = c4.concept_id "), settings = sqlSourceSettings)))

  val conditionOccurrenceMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/condition-occurrence-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select co.condition_occurrence_id, co.provider_id, co.visit_occurrence_id, " +
        "c.concept_code as condition_status_concept_code, c.vocabulary_id as condition_status_concept_vocab_id, c.concept_name as condition_status_concept_name, " +
        "co.person_id, c2.concept_code as condition_concept_code, c2.vocabulary_id as condition_concept_vocab_id, c2.concept_name as condition_concept_name, " +
        "co.condition_start_date, co.condition_start_datetime, co.condition_end_date, co.condition_end_datetime, co.stop_reason, " +
        "c3.concept_code as type_concept_code, c3.vocabulary_id as type_vocab_id, c3.concept_name as type_concept_name " +
        "from condition_occurrence co " +
        "left join concept c on co.condition_status_concept_id = c.concept_id " +
        "left join concept c2 on co.condition_concept_id = c2.concept_id " +
        "left join concept c3 on co.condition_type_concept_id = c3.concept_id"), settings = sqlSourceSettings)))

  val deviceExposureMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/device-exposure-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select de.device_exposure_id, de.provider_id, de.visit_occurrence_id, de.person_id, " +
        "de.device_exposure_start_date, de.device_exposure_start_datetime, de.device_exposure_end_date, de.device_exposure_end_datetime, " +
        "c.concept_code, c.vocabulary_id, c.concept_name, de.unique_device_id " +
        "from device_exposure de " +
        "left join concept c on de.device_type_concept_id = c.concept_id"), settings = sqlSourceSettings)))

  val specimenMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/specimen-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select s.specimen_id, s.person_id, c.concept_code, c.vocabulary_id, c.concept_name, s.specimen_date, s.specimen_datetime, " +
        "s.quantity, c2.concept_code as unit_code, c2.vocabulary_id as unit_system, " +
        "c3.concept_code as body_site_code, c3.vocabulary_id as body_site_vocab_id, c3.concept_name as body_site_name " +
        "from specimen s " +
        "left join concept c2 on s.unit_concept_id = c2.concept_id " +
        "left join concept c3 on s.anatomic_site_concept_id = c3.concept_id " +
        "left join concept c on s.specimen_concept_id = c.concept_id"), settings = sqlSourceSettings)))

  val observationMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/observation-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select o.observation_id, o.provider_id, o.visit_occurrence_id, o.person_id, " +
        "c.concept_code as unit_code, c.vocabulary_id as unit_vocab_id, c.concept_name as unit_name, o.value_as_number, " +
        "c2.concept_code, c2.vocabulary_id, c2.concept_name, " +
        "o.observation_date, o.observation_datetime, o.value_as_string, " +
        "c3.concept_code as value_as_concept_code, c3.vocabulary_id as value_as_vocab_id, c3.concept_name as value_as_concept_name " +
        "from observation o " +
        "left join concept c on o.unit_concept_id = c.concept_id " +
        "left join concept c2 on o.observation_concept_id = c2.concept_id " +
        "left join concept c3 on o.value_as_concept_id = c3.concept_id"), settings = sqlSourceSettings)))

  val measurementMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/measurement-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select m.measurement_id, m.provider_id, m.visit_occurrence_id, m.person_id, " +
        "c.concept_code as unit_code, c.vocabulary_id as unit_vocab_id, c.concept_name as unit_name, m.value_as_number, " +
        "c2.concept_code, c2.vocabulary_id, c2.concept_name, " +
        "m.range_low, m.range_high, m.measurement_date, m.measurement_datetime, " +
        "c3.concept_code as value_as_concept_code, c3.vocabulary_id as value_as_vocab_id, c3.concept_name as value_as_concept_name " +
        "from measurement m  " +
        "left join concept c on m.unit_concept_id = c.concept_id " +
        "left join concept c2 on m.measurement_concept_id = c2.concept_id " +
        "left join concept c3 on m.value_as_concept_id = c3.concept_id"), settings = sqlSourceSettings)))

  val drugExposureMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/drug-exposure-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select de.drug_exposure_id, de.stop_reason, de.refills, de.quantity, de.days_supply, " +
        "de.lot_number, de.sig, c.concept_code as route_concept_code, c.vocabulary_id as route_vocab_id, c.concept_name as route_concept_name, " +
        "de.provider_id, de.visit_occurrence_id, de.drug_source_value, de.person_id, " +
        "c2.concept_code as drug_concept_code, c2.vocabulary_id as drug_vocab_id, c2.concept_name as drug_concept_name, " +
        "de.drug_exposure_start_date, de.drug_exposure_start_datetime, de.drug_exposure_end_date, de.drug_exposure_end_datetime, " +
        "de.verbatim_end_date " +
        "from drug_exposure de " +
        "left join concept c on de.route_concept_id = c.concept_id " +
        "left join concept c2 on de.drug_concept_id = c2.concept_id"), settings = sqlSourceSettings)))

  val deathMappingTask: FhirMappingTask = FhirMappingTask(
    mappingRef = "https://aiccelerate.eu/fhir/mappings/omop/death-mapping",
    sourceContext = Map("source" -> SqlSource(
      query = Some("select d.person_id, d.death_date, d.death_datetime, " +
        "c.concept_code as type_concept_code, c.vocabulary_id as type_vocab_id, c.concept_name as type_concept_name, " +
        "c2.concept_code as cause_concept_code, c2.vocabulary_id as cause_vocab_id, c2.concept_name as cause_concept_name " +
        "from death d " +
        "left join concept c on d.death_type_concept_id = c.concept_id " +
        "left join concept c2 on d.cause_concept_id = c2.concept_id "), settings = sqlSourceSettings)))


  "Care site mapping" should "should read data from SQL source and map it" in {
      val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
      fhirMappingJobManager.executeMappingTaskAndReturn(task = careSiteMappingTask) map { results =>
        results.size shouldBe 2
        val organization1 = results.head
        FHIRUtil.extractResourceType(organization1) shouldBe "Organization"
        (organization1 \ "name").extract[String] shouldBe "Example care site name"
        (((organization1 \ "type").extract[Seq[JObject]].head \ "coding").extract[Seq[JObject]].head \ "code").extract[String] shouldBe "21"
        ((organization1 \ "address").extract[Seq[JObject]].head \ "state").extract[String] shouldBe "MO"
      }
    }

  it should "map test data and write it to FHIR repo successfully" in {
    //Send it to our fhir repo if they are also validated
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(careSiteMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Location mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = locationMappingTask) map { results =>
      results.size shouldBe 5
      val location = results.head
      FHIRUtil.extractResourceType(location) shouldBe "Location"
      ((location \ "address").extract[JObject] \ "line").extract[Seq[String]].head shouldBe "19 Farragut"
      ((location \ "address").extract[JObject] \ "state").extract[String] shouldBe "MO"
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(locationMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Procedure occurrence mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = procedureOccurrenceMappingTask) map { results =>
      results.size shouldBe 5
      val procedureOccurrence = results.head
      FHIRUtil.extractResourceType(procedureOccurrence) shouldBe "Procedure"
      (procedureOccurrence \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient", "906440")
      (procedureOccurrence \ "encounter" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Encounter", "43483680")
      ((procedureOccurrence \ "performer").extract[Seq[JObject]].head \ "actor" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Practitioner", "48878")
      (procedureOccurrence \ "performedDateTime").extract[String] shouldBe "2010-04-25"
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(procedureOccurrenceMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Person mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = personMappingTask) map { results =>
      results.size shouldBe 5
      val patient = results.head
      FHIRUtil.extractResourceType(patient) shouldBe "Patient"
      (patient \ "birthDate").extract[String] shouldBe "1923-05-01"
      (patient \ "gender").extract[String] shouldBe "male"
      ((patient \ "address").extract[Seq[JObject]].head \ "state").extract[String] shouldBe "MO"
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(personMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Visit occurrence mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = visitOccurrenceMappingTask) map { results =>
      results.size shouldBe 5
      val visitOccurrence = results.head
      FHIRUtil.extractResourceType(visitOccurrence) shouldBe "Encounter"
      (visitOccurrence \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient","1")
      ((visitOccurrence \ "participant").extract[Seq[JObject]].head \ "individual" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Practitioner","1")
      (visitOccurrence \ "period" \ "start").extract[String] shouldBe "2010-03-12"
      (visitOccurrence \ "period" \ "end").extract[String] shouldBe "2010-03-13"
      // TODO visit occurence -> Encounter.class is mandatory but no match on omop?
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(visitOccurrenceMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Condition occurrence mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task =  conditionOccurrenceMappingTask) map { results =>
      results.size shouldBe 5
      val conditionOccurrence = results.head
      FHIRUtil.extractResourceType(conditionOccurrence) shouldBe "Condition"
      (conditionOccurrence \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient","1")
      OffsetDateTime.parse((conditionOccurrence \ "onsetDateTime").extract[String]).toInstant shouldBe OffsetDateTime.parse("2010-03-12T05:00:00Z").toInstant
      (conditionOccurrence \ "abatementDateTime").extract[String] shouldBe "2010-03-23"
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(conditionOccurrenceMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Device exposure mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = deviceExposureMappingTask) map { results =>
      results.size shouldBe 10
      val deviceExposure = results.head
      FHIRUtil.extractResourceType(deviceExposure) shouldBe "DeviceUseStatement"
      ((deviceExposure \ "timingPeriod").extract[JObject] \ "start").extract[String] shouldBe "2009-03-06"
      ((deviceExposure \ "timingPeriod").extract[JObject] \ "end").extract[String] shouldBe "2009-03-06"
      (deviceExposure \ "source" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Practitioner","130895")
      (deviceExposure \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient","1")
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(deviceExposureMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Specimen mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = specimenMappingTask) map { results =>
      results.size shouldBe 1
      val specimen = results.head
      FHIRUtil.extractResourceType(specimen) shouldBe "Specimen"
      (specimen \ "collection" \ "collectedDateTime").extract[String] shouldBe "2004-08-05"
      (specimen \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient","1")
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(specimenMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

    "Observation mapping" should "should read data from SQL source and map it" in {
      val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
      fhirMappingJobManager.executeMappingTaskAndReturn(task = observationMappingTask) map { results =>
        results.size shouldBe 5
        val observation = results.head
        FHIRUtil.extractResourceType(observation) shouldBe "Observation"
        OffsetDateTime.parse((observation \ "effectiveDateTime").extract[String]).toInstant shouldBe OffsetDateTime.parse("2009-11-17T05:00:00Z").toInstant
        (observation \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient", "3")
        (observation \ "encounter" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Encounter", "29804754")
      }
    }

    it should "map test data and write it to FHIR repo successfully" in {
      assume(fhirServerIsAvailable)
      fhirMappingJobManager
        .executeMappingJob(tasks = Seq(observationMappingTask), sinkSettings = fhirSinkSetting)
        .map(unit =>
          unit shouldBe()
        )
    }

  "Measurement mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = measurementMappingTask) map { results =>
      results.size shouldBe 1
      val observation = results.head
      FHIRUtil.extractResourceType(observation) shouldBe "Observation"
      OffsetDateTime.parse((observation \ "effectiveDateTime").extract[String]).toInstant shouldBe OffsetDateTime.parse("2002-10-13T12:59:00Z").toInstant
      (observation \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient", "1")
      (observation \ "encounter" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Encounter", "1")
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(measurementMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Drug exposure mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = drugExposureMappingTask) map { results =>
      results.size shouldBe 15
      val drugExposure = results.head
      FHIRUtil.extractResourceType(drugExposure) shouldBe "MedicationStatement"
      (drugExposure \ "effectivePeriod" \ "start").extract[String] shouldBe "2010-12-03"
      (drugExposure \ "effectivePeriod" \ "end").extract[String] shouldBe "2011-01-21"
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(drugExposureMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

  "Death mapping" should "should read data from SQL source and map it" in {
    val fhirMappingJobManager = new FhirMappingJobManager(mappingRepository, contextLoader, schemaRepository, sparkSession, mappingErrorHandling)
    fhirMappingJobManager.executeMappingTaskAndReturn(task = deathMappingTask) map { results =>
      results.size shouldBe 5
      val death = results.head
      FHIRUtil.extractResourceType(death) shouldBe "AdverseEvent"
      OffsetDateTime.parse((death \ "date").extract[String]).toInstant shouldBe OffsetDateTime.parse("2010-12-01T05:00:00Z").toInstant
      (death \ "subject" \ "reference").extract[String] shouldBe FhirMappingUtility.getHashedReference("Patient", "1")
    }
  }

  it should "map test data and write it to FHIR repo successfully" in {
    assume(fhirServerIsAvailable)
    fhirMappingJobManager
      .executeMappingJob(tasks = Seq(deathMappingTask), sinkSettings = fhirSinkSetting)
      .map(unit =>
        unit shouldBe()
      )
  }

}

