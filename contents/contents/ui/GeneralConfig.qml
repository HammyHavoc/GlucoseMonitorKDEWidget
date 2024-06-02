import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_nightscoutInstance: nightscoutInstanceTextField.text
    property alias cfg_accessToken: accessTokenTextField.text
    property alias cfg_unit: unitComboBox.currentIndex
    property string logMessages: plasmoid.configuration.logMessages
    property string mostRecentTimestamp: plasmoid.configuration.mostRecentTimestamp

    ColumnLayout {
        spacing: units.smallSpacing * 2

        RowLayout {
            Label {
                text: i18n("Nightscout Instance")
            }
            TextField {
                id: nightscoutInstanceTextField
                text: plasmoid.configuration.nightscoutInstance
                placeholderText: i18n("e.g., https://nightscout.splitanatom.com")
                onTextChanged: {
                    let baseURL = text.split("/api/")[0]; // Remove any API path if present
                    plasmoid.configuration.nightscoutInstance = baseURL;
                }
            }
        }

        RowLayout {
            Label {
                text: i18n("Access Token")
            }
            TextField {
                id: accessTokenTextField
                text: plasmoid.configuration.accessToken
                onTextChanged: plasmoid.configuration.accessToken = text
            }
        }

        RowLayout {
            Label {
                text: i18n("Unit")
            }
            ComboBox {
                id: unitComboBox
                model: ["mmol/L", "mg/dL"]
                currentIndex: plasmoid.configuration.unit
                onCurrentIndexChanged: plasmoid.configuration.unit = currentIndex
            }
        }

        RowLayout {
            Label {
                text: "Debug Log"
            }
        }

        TextArea {
            id: logArea
            text: configRoot.logMessages
            readOnly: true
            width: parent.width
            height: 200
        }

        RowLayout {
            Label {
                text: configRoot.mostRecentTimestamp ? i18n("Most recent data from: ") + configRoot.mostRecentTimestamp : i18n("No data received from Nightscout yet.")
            }
        }

        RowLayout {
            Label {
                text: i18n("Last query attempt:")
            }
            Label {
                text: new Date().toLocaleString()
            }
        }
    }

    function appendLogMessage(message) {
        configRoot.logMessages += message + "\n";
        plasmoid.configuration.logMessages = configRoot.logMessages;
        plasmoid.configuration.writeConfig();
    }
}
