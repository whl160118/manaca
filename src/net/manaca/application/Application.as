package net.manaca.application
{
import flash.display.Sprite;
import flash.utils.Dictionary;

import net.manaca.application.config.BaseApplicationConfiguration;
import net.manaca.application.config.model.ConfigurationInfo;
import net.manaca.application.thread.BatchEvent;
import net.manaca.application.thread.ProcessEvent;
import net.manaca.core.AbstractHandler;
import net.manaca.errors.FrameworkError;
import net.manaca.errors.IllegalArgumentError;
import net.manaca.errors.SingletonError;

/**
 * <code>Application</code> is the default access point for flash applications.
 *
 * <p>You can use a Frame tag define a <code>Preloader</code> object.</p>
 *
 * <p>You must simply init your application something like this:</p>
 * <listing version = "3.0" >
 * package {
import net.manaca.application.Application;
[Frame(factoryClass="net.manaca.preloaders.SimplePreloader")]
public class ApplicationExample extends Application
{
[Embed(source="./application.xml", mimeType="application/octet-stream")]
private var configClz:Class;

public function ApplicationExample()
{
super(configClz);
}

override protected function startup():void
{
}
}
}
 * </listing>
 *
 * @author Sean Zou
 */
public class Application extends Sprite implements IApplication
{
    //==========================================================================
    //  Class variables
    //==========================================================================
    /* Singleton for this application */
    private static var instance:Application;
    //==========================================================================
    //  Class methods
    //==========================================================================
    /**
     * Get external files.
     * @return
     *
     */
    static public function get externalFiles():Dictionary
    {
        return instance.configuration.externalFiles;
    }

    /**
     * Get the application config by config XML.
     * @return
     *
     */
    static public function get config():ConfigurationInfo
    {
        return instance.configuration.configInfo;
    }

    /**
     * Get the project settings by config XML.
     * @return
     *
     */
    static public function get projectSettings():Dictionary
    {
        return instance.configuration.projectSettings;
    }

    //==========================================================================
    //  Variables
    //==========================================================================

    private var config:*;
    private var configuration:BaseApplicationConfiguration;

    /**
     * Constructs a new <code>Application</code> instance.
     * @param config the config xml class.
     * you can writing something like this:
     * <listing version = "3.0" >
     * [Embed(source="./application.xml", mimeType="application/octet-stream")]
     * private var configClz:Class;
     * </listing>
     */
    public function Application(config:*)
    {
        AbstractHandler.handlerClass(this, Application);

        if(config != null)
        {
            this.config = config;
        }
        else
        {
            throw new IllegalArgumentError(
                                    "invalid config argument:" + config);
        }

        if(instance != null)
        {
            throw new SingletonError(this);
        }
        else
        {
            instance = this;
        }
    }

    //==========================================================================
    //  Methods
    //==========================================================================
    /**
     * @inheritDoc
     */
    final public function initialize():void
    {
        configuration = new BaseApplicationConfiguration(stage, config);
        configuration.addEventListener(BatchEvent.BATCH_FINISH, 
                                            configurationFinishHandler);
        configuration.addEventListener(BatchEvent.BATCH_UPDATE, 
                                            configurationUpdateHandler);
        configuration.addEventListener(BatchEvent.BATCH_ERROR, 
                                            configurationBatchErrorHandler);
        configuration.addEventListener(ProcessEvent.PROCESS_ERROR, 
                                            configurationProcessErrorHandler);
        configuration.start();
    }

    /**
     * The startup function will call by application initialized.
     * You need override the function.
     * <p>for example:</p>
     * @example
     * <pre>
     * final override public function startup(...rest):void
     * {
     *         trace("The application started!")
     * }
     * </pre>
     * @throws net.manaca.errors.AbstractOperationError thrown the error 
     * indicate that an operation marked by the developer has not override 
     * the abstract function.
     */
    protected function startup():void
    {
        AbstractHandler.handlerFunction("Application.startup");
    }

    /**
     * The updateConfiguration function will call by configuration update.
     * You can override the function.
     * @param percent
     *
     */
    protected function updateConfiguration(percentage:uint):void
    {
    }

    /**
     * The updateConfiguration function will call by 
     * configuration catched a error.
     * You can override the function.
     * @param error the catched error.
     *
     */
    protected function errorHandler(error:Error):void
    {
        throw new FrameworkError(error.toString());
    }

    /**
     * remove configuration events.
     *
     */
    private function removeConfigurationEvents():void
    {
        configuration.removeEventListener(BatchEvent.BATCH_FINISH, 
                                        configurationFinishHandler);
        configuration.removeEventListener(BatchEvent.BATCH_UPDATE, 
                                        configurationUpdateHandler);
        configuration.removeEventListener(BatchEvent.BATCH_ERROR, 
                                        configurationBatchErrorHandler);
        configuration.removeEventListener(ProcessEvent.PROCESS_ERROR, 
                                        configurationProcessErrorHandler);
    }

    //==========================================================================
    //  Event handlers
    //==========================================================================
    /**
     * handle configuration finish event.
     * @param event
     *
     */
    private function configurationFinishHandler(event:BatchEvent):void
    {
        removeConfigurationEvents();
        configuration.clear();
        startup();
    }

    /**
     * handle configuration update event.
     * @param event
     *
     */
    private function configurationUpdateHandler(event:BatchEvent):void
    {
        updateConfiguration(event.percentage);
    }

    /**
     * handle configuration batch error event.
     * @param event
     *
     */
    private function configurationBatchErrorHandler(event:BatchEvent):void
    {
        errorHandler(event.error);
    }

    /**
     * handle configuration process error event.
     * @param event
     *
     */
    private function configurationProcessErrorHandler(event:ProcessEvent):void
    {
        errorHandler(event.error);
    }
}
}