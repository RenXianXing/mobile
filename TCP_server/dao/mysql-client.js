/**
 * Created by Administrator on 8/12/2016.
 */

"use strict";

var mysql = require("mysql");
const database = "ridebogo_db";

function getMySqlClient() {
    var con = mysql.createConnection({
        host: 'localhost',
        user: 'ridebogo_thai',
        password: 'U?uQp%Q%$Su4',
        database:database,
        timezone: 'utc'
    });

    con.connect(function(err) {
        if (err) {
            setTimeout(getMySqlClient(), 2000)
        };
        console.log("Connected!");

        con.query('CREATE DATABASE IF NOT EXISTS ' + database, function(err) {
            if ( err && err.number != mysql.ERROR_DB_CREATE_EXISTS ) {
                throw err;
            }
        });
        con.query('USE ' + database);

    });
    return con;
}

exports.mysqlClient = getMySqlClient;