package algorithmia.helloworld


import algorithmia.helloworld.HelloWorldAlgorithmFeatureSpec.config
import uk.gov.ons.es.it.AlgorithmFeatureSpec
import uk.gov.ons.es.it.AlgorithmiaSupport.{AlgorithmiaConfig, withAlgorithmiaClient}

class HelloWorldAlgorithmFeatureSpec extends AlgorithmFeatureSpec {
  feature("Hello World algorithm") {
    scenario("the input to the algorithm is a name") {
      withAlgorithmiaClient(config.clientConfig) { client =>
        When("the algorithm is supplied a name")
        val response = client.algo(config.algorithmDescriptor).pipe("Bob")

        Then("a suitable greeting is returned")
        response.asString() shouldBe "Hello Bob"
      }
    }
  }
}

private object HelloWorldAlgorithmFeatureSpec {
  val config = AlgorithmiaConfig.load()
}
