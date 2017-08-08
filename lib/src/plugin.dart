library web.plugin;
import "./web.dart" show Application;

abstract class Plugin{
    void init(Application app);
}
