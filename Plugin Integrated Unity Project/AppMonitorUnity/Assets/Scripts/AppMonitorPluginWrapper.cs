using System.Runtime.InteropServices;

public class AppMonitorPluginWrapper
{
#if UNITY_IOS
	[DllImport("__Internal", EntryPoint = "startAppMonitor")] private static extern void startAppMonitor();
	[DllImport("__Internal", EntryPoint = "stopAppMonitor")] private static extern string stopAppMonitor();
#endif

	public void StartMonitor()
	{
#if UNITY_IOS
		startAppMonitor();
#endif
	}

	public string StopMonitor()
	{
#if UNITY_IOS
		return stopAppMonitor();
#else
		return "STOPPED THE APP MONITOR";
#endif
	}
}

