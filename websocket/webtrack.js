const Websocket = require("ws");
require("dotenv").config();
const mysql = require("mysql");
const wss = new Websocket.Server({ port: process.env.PORT });

const clients = {};
const devices = {};
const MESSAGE_TIMEOUT = 5000;

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATA,
});

db.connect((err) => {
  if (err) {
    console.error("Error connecting to database");
    return;
  }
  console.log("Connected to database");
});

wss.on("connection", async function connection(ws, req) {
  console.log("New incoming connection");

  const deviceId = req.headers.deviceid;
  const clientId = req.headers.clientid;

  if (!deviceId && !clientId) {
    console.log("Invalid connection: missing device ID or Client ID");
    ws.terminate();
    return;
  }

  if (deviceId) {
    db.query(
      "SELECT * FROM devices WHERE device_id = ?",
      [deviceId],
      (err, results) => {
        if (err) {
          console.error("Error querying database:", err);
          ws.terminate();
          return;
        }
        if (results.length === 0) {
          console.log("Device ID not found in database:", deviceId);
          ws.terminate();
          return;
        }
        devices[deviceId] = { ws, lastMessageTime: Date.now() };
        ws.deviceid = deviceId;
        console.log("Device connected:", deviceId);
        updateDeviceState(deviceId, "1");
      }
    );
  }

  if (clientId) {
    db.query(
      "SELECT * FROM trains WHERE client_id = ?",
      [clientId],
      (err, results) => {
        if (err) {
          console.error("Error querying database:", err);
          ws.terminate();
          return;
        }
        if (results.length === 0) {
          console.log("Client ID not found in database:", clientId);
          ws.terminate();
          return;
        }
        ws.clientid = clientId;
        clients[clientId] = ws;
        console.log("Client connected:", clientId);
      }
    );
  }

  ws.on("message", async function (message) {
    if (message.length > 1) {
      try {
        const data = JSON.parse(message);
        handleMessage(data, deviceId, clientId);
        if (devices[deviceId]) {
          devices[deviceId].lastMessageTime = Date.now();
        }
      } catch (error) {
        console.error("Error parsing message:", error);
      }
    }
  });

  ws.on("close", function close() {
    console.log("Connection closed");
    if (deviceId) {
      delete devices[deviceId];
      console.log("Device disconnected:", deviceId);
      updateDeviceState(deviceId, "0");
    }
    if (clientId) {
      console.log("Client disconnected:", clientId);
      delete clients[clientId];
    }
  });
});

function handleMessage(data, deviceId, clientId) {
  if (deviceId) {
    console.log("Message received from device:", deviceId);
    const query = `SELECT client_id AS clientId FROM trains WHERE device_id = ?`;
    db.query(query, [deviceId], (err, results) => {
      if (err) {
        console.error("Error querying database:", err);
        return;
      }
      if (results.length === 0) {
        console.log("Client ID not found for deviceId: ", deviceId);
        return;
      }
      const dbClientId = results[0].clientId;
      wss.clients.forEach(function each(ws) {
        if (ws.clientid == dbClientId) {
          ws.send(JSON.stringify(data));
          console.log("Data sent to client:", dbClientId);
        } else {
          console.log("Client not connected: ", dbClientId);
        }
      });
    });
  } else if (clientId) {
    console.log("Message received from client:", clientId);
  }
}

async function updateDeviceState(deviceId, state) {
  const query = "UPDATE devices SET state = ? WHERE device_id = ?";
  db.query(query, [state, deviceId], (err, results) => {
    if (err) {
      console.error("Error updating device state:", err);
      return;
    }
    console.log(`Device state updated: ${deviceId} is ${state}`);
  });
}

setInterval(() => {
  const currentTime = Date.now();
  Object.keys(devices).forEach((deviceId) => {
    const { lastMessageTime, ws } = devices[deviceId];
    if (currentTime - lastMessageTime > MESSAGE_TIMEOUT) {
      console.log(
        "No message received from device",
        deviceId,
        "within timeout. Terminating connection."
      );
      ws.terminate();
      delete devices[deviceId];
      updateDeviceState(deviceId, "0");
    }
  });
}, 5000);

wss.on("error", function (error) {
  console.error("WebSocket server error:", error);
});
