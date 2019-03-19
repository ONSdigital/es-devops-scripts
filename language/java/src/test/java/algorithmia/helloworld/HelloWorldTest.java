package algorithmia.helloworld;


import org.junit.Test;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.MatcherAssert.assertThat;

public class HelloWorldTest {

    private final HelloWorld underTest;

    public HelloWorldTest() {
        underTest = new HelloWorld();
    }

    @Test
    public void testHelloWorld() throws Exception {
        assertThat(underTest.apply("Bob"), equalTo("Hello Bob"));
    }
}
