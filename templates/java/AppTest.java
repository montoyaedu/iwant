package ${RootNamespace};

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit test for ${AssemblyName}
 */
public class ${AssemblyName}Test 
    extends TestCase
{
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public ${AssemblyName}Test( String testName )
    {
        super( testName );
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( ${AssemblyName}Test.class );
    }

    /**
     * Rigourous Test :-)
     */
    public void test${AssemblyName}()
    {
        String[] args = new String[]{};
        ${AssemblyName}.main(args);
        assertTrue( true );
    }
}
