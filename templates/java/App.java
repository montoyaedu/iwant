package ${RootNamespace};

import java.util.logging.Logger;

/**
 * ${AssemblyName}
 *
 */
public class ${AssemblyName}
{
    private static final Logger LOGGER = 
        Logger.getLogger(${AssemblyName}.class.getName());

    private ${AssemblyName}()
    {
    }

    public static void main( String[] args )
    {
        ${AssemblyName} x = new ${AssemblyName}();
        x.sayHello();
    }

    public void sayHello()
    {
        LOGGER.info( "Hello World!" );
    }
}
