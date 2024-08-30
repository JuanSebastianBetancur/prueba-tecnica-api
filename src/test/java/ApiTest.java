import com.intuit.karate.junit5.Karate;

public class ApiTest {

    @Karate.Test
    Karate testExample() {
        return Karate.run("classpath:test.feature");
    }
}