using UnityEngine;
using UnityEngine.UI;
using System.IO;

public class AppMonitorUI : MonoBehaviour
{
	[SerializeField] private Button startMonitorButton;
	[SerializeField] private Button stopMonitorButton;
	[SerializeField] private Text metricsText;
	private AppMonitorPluginWrapper appMonitor = null;
	private string metricsFile = "/MetricsLog.txt";
	private void Start()
	{
			appMonitor = new AppMonitorPluginWrapper();
			
			startMonitorButton.onClick.AddListener(()=>{
				appMonitor.StartMonitor();
			});


			stopMonitorButton.onClick.AddListener(()=>{
				string text = appMonitor.StopMonitor();
				metricsText.text = text;
				File.WriteAllText(Application.persistentDataPath + metricsFile, text);
			});
	}		   
}