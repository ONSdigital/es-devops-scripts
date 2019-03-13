package uk.gov.ons.es.it


import com.algorithmia.{Algorithmia, AlgorithmiaClient}
import com.typesafe.config.{Config, ConfigFactory}

object AlgorithmiaSupport {
  final case class AlgorithmiaClientConfig(apiKey: String, apiAddress: String)
  final case class AlgorithmiaConfig(clientConfig: AlgorithmiaClientConfig, algorithmDescriptor: String)

  def withAlgorithmiaClient[A](clientConfig: AlgorithmiaClientConfig)(f: AlgorithmiaClient => A): A = {
    val client = Algorithmia.client(clientConfig.apiKey, clientConfig.apiAddress)
    try f(client)
    finally client.close()
  }

  object AlgorithmiaConfig {
    def load(): AlgorithmiaConfig = {
      val rootConfig = ConfigFactory.load()
      val config = rootConfig.getConfig("algorithmia")
      AlgorithmiaConfig(
        clientConfig = loadClientConfigFrom(config),
        algorithmDescriptor = config.getString("algorithm.descriptor")
      )
    }

    private def loadClientConfigFrom(config: Config): AlgorithmiaClientConfig =
      AlgorithmiaClientConfig(
        apiKey = config.getString("simpleApiKey"),
        apiAddress = config.getString("apiAddress")
      )
  }
}