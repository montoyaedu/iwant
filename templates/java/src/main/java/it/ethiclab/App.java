package it.ethiclab;

import java.util.logging.Logger;

/**
 * Hello world!
 *
 */
public class App 
{
    private static final Logger LOGGER = 
        Logger.getLogger(App.class.getName());

    private App()
    {
    }

    public static void main( String[] args )
    {
        App x = new App();
        x.sayHello();
    }

    public void sayHello()
    {
        LOGGER.info( "Hello World!" );
    }
}
