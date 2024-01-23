package at.wbi.tika;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Properties;

public class Service {

	private static final String CONFIG_PATH = "config/service.config";

	private static boolean DEBUG = false;

	private static final String MAIN_CLASS_NAME = "org.apache.tika.server.core.TikaServerCli";

	public static void start(String[] args) {
		System.out.println("starting... TikaService");

		try {
			// Get the actual class containing the main method of the Tika Server
			Class<?> clazz = Class.forName(MAIN_CLASS_NAME);
			Method method = clazz.getMethod("main", String[].class);
			method.setAccessible(true);

			// generate parameters for the server
			ArrayList<String> serverArgs = new ArrayList<String>();

			Properties props = new Properties();
			props.load(new FileInputStream(new File(CONFIG_PATH)));
			
			serverArgs.add("--host");
			serverArgs.add(props.getProperty("host"));

			serverArgs.add("--log");
			if (DEBUG) {
				serverArgs.add("debug");
			} else {
				serverArgs.add("info");
			}

			serverArgs.add("--port");
			serverArgs.add(props.getProperty("port"));

			if (DEBUG) {
				serverArgs.add("--includeStack");
			}

			if ("true".equalsIgnoreCase(props.getProperty("enableUnsecureFeatures"))) {
				serverArgs.add("--enableUnsecureFeatures");
			}
			
			if ("true".equalsIgnoreCase(props.getProperty("enableFileUrl"))) {
				serverArgs.add("--enableFileUrl");
			}
			
			if (!props.get("digest").toString().isEmpty()) {
				serverArgs.add("--digest");
				serverArgs.add(props.get("digest").toString());
			}
			
			serverArgs.add("--cors");
			serverArgs.add(props.getProperty("cors"));

			if ("true".equalsIgnoreCase(props.getProperty("spawnChild"))) {
				serverArgs.add("--spawnChild");
				
				serverArgs.add("--taskTimeoutMillis");
				serverArgs.add(props.getProperty("taskTimeoutMillis"));
				
				serverArgs.add("--taskPulseMillis");
				serverArgs.add(props.getProperty("taskPulseMillis"));
				
				serverArgs.add("--pingTimeoutMillis");
				serverArgs.add(props.getProperty("pingTimeoutMillis"));
				
				serverArgs.add("--pingPulseMillis");
				serverArgs.add(props.getProperty("pingPulseMillis"));
				
				serverArgs.add("--maxFiles");
				serverArgs.add(props.getProperty("maxFiles"));
			}
			
			System.out.println("TikaServerCli Args: " + String.join(" ", serverArgs));
			
			// Call the actual main method.
			method.invoke(null, (Object)serverArgs.toArray(new String[0]));
		} catch (Exception e) {
			e.printStackTrace(); // gets printed in std-err
		}
	}

	public static void stop(String[] args) {
		System.out.println("stopping... TikaService");
		Runtime.getRuntime().exit(0);
	}
}
