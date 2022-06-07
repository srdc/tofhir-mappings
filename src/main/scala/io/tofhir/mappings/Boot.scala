package io.tofhir.mappings

import io.onfhir.tofhir.ToFhirEngine
import io.onfhir.tofhir.cli.CommandLineInterface
import io.onfhir.tofhir.config.ToFhirConfig

/**
 * Entrypoint of app
 */
object Boot extends App {
  val toFhirEngine = new ToFhirEngine(ToFhirConfig.appName, ToFhirConfig.sparkMaster,
    ToFhirConfig.mappingRepositoryFolderPath, ToFhirConfig.schemaRepositoryFolderPath)

  CommandLineInterface.start(toFhirEngine)
}
