# This repository contains the swift framework and Unity project with the swift plugin integrated to monitor the cpu usage, gpu usage and ram usage.
# This repository also contains the generated XCode project to run the test application.
# In the application, clicking on Start calls the swift code to monitor the metrics and when stop is clicked the monitoring is stopped.
# Once monitoring is done, the metrics are converted to json string and sent back to Unity and it is shown in the text view in the application and saved to a file in the application persistant path.
# swift code to monitor metrics - https://github.com/AuremMJS/SwiftAppMonitorUnityPlugin/blob/main/SwiftFramework/AppMonitor_Plugin/AppMonitor_Plugin/AppMonitor_Plugin/AppMonitorPlugin.swift
# Unity C# code to use the swift functions - https://github.com/AuremMJS/SwiftAppMonitorUnityPlugin/blob/main/Plugin%20Integrated%20Unity%20Project/AppMonitorUnity/Assets/Scripts/AppMonitorPluginWrapper.cs
