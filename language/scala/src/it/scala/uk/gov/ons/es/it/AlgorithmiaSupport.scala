package uk.gov.ons.es.it


import com.algorithmia.{Algorithmia, AlgorithmiaClient}
import com.typesafe.config.ConfigFactory

object AlgorithmiaSupport {
  def withAlgorithmiaClient[A](simpleApiKey: String)(f: AlgorithmiaClient => A): A = {
    val client = Algorithmia.client(simpleApiKey)
    try f(client)
    finally client.close()
  }

  final case class AlgorithmiaConfig(apiKey: String, algorithmDescriptor: String)

  object AlgorithmiaConfig {
    def load(): AlgorithmiaConfig = {
      val config = ConfigFactory.load().getConfig("algorithmia")
      AlgorithmiaConfig(
        apiKey = config.getString("simpleApiKey"),
        algorithmDescriptor = config.getString("algorithm.descriptor")
      )
    }
  }
}
