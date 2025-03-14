const { DataTypes } = require("sequelize");
const sequelize = require("./index");

const HealthCheck = sequelize.define(
  "HealthCheck",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    datetime: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    tableName: "ApplicationHealth",
    timestamps: false,
  }
);

module.exports = HealthCheck;
