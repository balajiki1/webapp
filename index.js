const sequelize = require("./models/index");
const express = require("express");
const HealthCheck = require("./models/healthcheck");

const app = express();
const PORT = 8080;

app.use(express.json({ strict: true }));

app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && "body" in err) {
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    return res.status(400).end();
  }
  next();
});

app.get("/healthz", async (req, res) => {
  // ❌ Reject request if body, query params, or extra headers exist
  if (req.body && Object.keys(req.body).length > 0) {
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    return res.status(400).end();
  }
  
  if (Object.keys(req.query).length > 0) {
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    return res.status(400).end();
  }

  try {
    await HealthCheck.create({ datetime: new Date() });

    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    res.status(200).end();
  } catch (error) {
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    res.status(503).end();
  }
});

app.all("/healthz", (req, res) => {
  if (req.method !== "GET") {
    res.set("Cache-Control", "no-cache, no-store, must-revalidate");
    res.set("Pragma", "no-cache");
    return res.status(405).end();
  }
});

// 🛑 Prevent running the server during tests
if (process.env.NODE_ENV !== "test") {
  (async () => {
    try {
      await sequelize.authenticate();
      console.log("Connection to MySQL has been established successfully.");
      await sequelize.sync({ alter: true });
      console.log("Database synchronized!");

      app.listen(PORT, () => {
        console.log(`Server is running on http://localhost:${PORT}`);
      });
    } catch (error) {
      console.error("Unable to connect to the database:", error);
      process.exit(1);
    }
  })();
}

module.exports = app;
