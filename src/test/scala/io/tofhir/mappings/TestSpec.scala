package io.tofhir.mappings

import akka.actor.ActorSystem
import io.tofhir.engine.config.ErrorHandlingType.ErrorHandlingType
import io.tofhir.engine.config.{ErrorHandlingType, ToFhirConfig}
import org.apache.spark.SparkConf
import org.apache.spark.sql.SparkSession
import org.scalatest.flatspec.AsyncFlatSpec
import org.scalatest.matchers.should
import org.scalatest.{Inside, Inspectors, OptionValues}

abstract class TestSpec extends AsyncFlatSpec with should.Matchers with
  OptionValues with Inside with Inspectors {

  implicit val actorSystem: ActorSystem = ActorSystem("omopTest")

  val mappingErrorHandling: ErrorHandlingType = ErrorHandlingType.HALT
  val fhirWriteErrorHandling: ErrorHandlingType = ErrorHandlingType.HALT

  val sparkConf: SparkConf = new SparkConf()
    .setAppName(ToFhirConfig.sparkAppName)
    .setMaster(ToFhirConfig.sparkMaster)
    .set("spark.driver.allowMultipleContexts", "false")
    .set("spark.ui.enabled", "false")
  val sparkSession: SparkSession = SparkSession.builder().config(sparkConf).getOrCreate()
}
