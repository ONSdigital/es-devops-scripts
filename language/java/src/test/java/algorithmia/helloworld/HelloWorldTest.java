package algorithmia.helloworld;


import junit.framework.TestCase;
import org.junit.Test;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.MatcherAssert.assertThat;

public class HelloWorldTest extends TestCase {

    private final HelloWorld underTest;

    public HelloWorldTest() {
        underTest = new HelloWorld();
    }

    @Test
    public void testhwj() throws Exception {
        assertThat(underTest.apply("Bob"), equalTo("Hello Bob"));
    }
}
