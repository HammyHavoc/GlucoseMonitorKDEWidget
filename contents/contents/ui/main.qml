import QtQuick 2.15
import QtQuick.Controls 2.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.ConfigurableBackground

    Label {
        id: testLabel
        text: "Testing command execution..."
        anchors.centerIn: parent
        font.family: "Arial"
        font.pointSize: 12
    }

    Component.onCompleted: {
        fetchData();
    }

    function fetchData() {
        appendLogMessage("Creating QProcess instance");
        var process = new QProcess(root);

        var nightscoutInstance = plasmoid.configuration.nightscoutInstance;
        var accessToken = plasmoid.configuration.accessToken;
        var scriptPath = Qt.resolvedUrl("fetch_glucose.sh");
        appendLogMessage("Script path: " + scriptPath);

        var args = [nightscoutInstance, accessToken];

        appendLogMessage("Connecting process signals");
        process.finished.connect(function(exitCode, exitStatus) {
            appendLogMessage("Process Finished. Exit Code: " + exitCode + ", Exit Status: " + exitStatus);
            var response = process.readAllStandardOutput();
            appendLogMessage("Response: " + response);
            try {
                var data = JSON.parse(response);
                if (data.length > 0) {
                    var entry = data[0];
                    var timestamp = entry.dateString;
                    appendLogMessage("Most recent data timestamp: " + timestamp);
                    plasmoid.configuration.mostRecentTimestamp = timestamp;
                    plasmoid.configuration.writeConfig();
                    testLabel.text = entry.sgv + " mmol/L, " + entry.direction;
                } else {
                    testLabel.text = "No data available";
                }
            } catch (e) {
                appendLogMessage("JSON Parsing error: " + e.toString());
                testLabel.text = "Parsing error!";
            }
        });

        process.errorOccurred.connect(function(error) {
            appendLogMessage("Process Error: " + process.errorString());
            testLabel.text = "Error: " + process.errorString();
        });

        process.started.connect(function() {
            appendLogMessage("Process started successfully");
        });

        process.stateChanged.connect(function(newState) {
            appendLogMessage("Process state changed: " + newState);
        });

        process.readyReadStandardOutput.connect(function() {
            appendLogMessage("Ready to read standard output");
        });

        process.readyReadStandardError.connect(function() {
            appendLogMessage("Ready to read standard error");
        });

        appendLogMessage("Starting process: " + scriptPath + " " + args.join(" "));
        process.start(scriptPath, args);

        appendLogMessage("Waiting for process to start");
        if (!process.waitForStarted()) {
            appendLogMessage("Process failed to start: " + process.errorString());
        } else {
            appendLogMessage("Process start command issued");
        }
    }

    function appendLogMessage(message) {
        plasmoid.configuration.logMessages += message + "\n";
        plasmoid.configuration.writeConfig();
    }
}
