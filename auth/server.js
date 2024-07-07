const paypal = require("paypal-rest-sdk");
const moment = require("moment");
const express = require("express");
const bodyParser = require("body-parser");
const mysql = require("mysql");
const jwt = require("jsonwebtoken");
const app = express();
const randomstring = require("randomstring");
const uuid = require("uuid");
const bcrypt = require("bcrypt");
app.use(bodyParser.json());
require("dotenv").config();

const clientId = process.env.clientId;
const secret = process.env.secret;
const JWT_SECRET = process.env.JWT_SECRET;
const PORT = process.env.PORT;

paypal.configure({
  mode: "sandbox",
  client_id: clientId,
  client_secret: secret,
});

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_DATABASE,
});

db.connect((err) => {
  if (err) {
    console.log("Error connecting to database: ", err);
  } else {
    console.log("Connected to database");
  }
});

app.post("/pay", (req, res) => {
const {userid} = req.query;
  const { total } = req.body;

  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const create_payment_json = {
        intent: "sale",
        payer: {
          payment_method: "paypal",
        },
        redirect_urls: {
          return_url: "https://trackwise.pasiyaprogramming.live/success",
          cancel_url: "https://trackwise.pasiyaprogramming.live/cancel",
        },
        transactions: [
          {
            amount: {
              currency: "USD",
              total: total,
            },
            description: "Checkout",
          },
        ],
      };

      app.get("/success", (req, res) => {
        const payerId = req.query.PayerID;
        const paymentId = req.query.paymentId;
        try {
          paypal.payment.get(paymentId, async function (err, payment) {
            if (err) {
              console.error("Error: ", err);
            } else {
              const totalamount = payment.transactions[0].amount.total;
              const execute_payment_json = {
                payer_id: payerId,
                transactions: [
                  {
                    amount: {
                      currency: "USD",
                      total: totalamount,
                    },
                  },
                ],
              };
              paypal.payment.execute(
                paymentId,
                execute_payment_json,
                function (error, payment) {
                  if (error) {
                    console.log(error.response);
                    throw error;
                  } else {
                    console.log(payment);
                    var id = payment.id;
                    var state = payment.state;
                    var email = payment.payer.payer_info.email;
                    var total = totalamount;
                    const transid = randomstring.generate({
                      length: 8,
                      charset: "numeric",
                    });
                    const transactionid = `trans${transid}`;
                    const insertquery = `INSERT INTO transactions VALUES (?, ?, ?, ?, ?, ?, TIMESTAMP(CURRENT_TIMESTAMP))`;
console.log("User ID: ", userid);
                    db.query(
                      insertquery,
                      [transactionid, id, userid, email, state, total],
                      async (err, result) => {
                        if (err) {
                          return console.log("Error inserting database: ", err);
                        }
                        if (result.length === 0) {
                          return console.log("Error");
                        } else {
                          console.log("Insert data success");
                        }
                      }
                    );
                    res.send("Success");
                  }
                }
              );
            }
          });
        } catch (err) {
          console.error(err);
        }
      });
      paypal.payment.create(create_payment_json, function (error, payment) {
        if (error) {
          throw error;
        } else {
          for (let i = 0; i < payment.links.length; i++) {
            if (payment.links[i].rel === "approval_url") {
              res.status(200).json({link: payment.links[i].href});
            }
          }
        }
      });
    }
  });
});

app.get("/cancel", (req, res) => res.send("Cancelled"));

app.get("/getpaymentdetails", async (req, res) => {
  const { userid } = req.query;

  if (!userid) {
    res.status(400).json({ message: "User ID required" });
    return;
  }

  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const query = `SELECT transaction_id, date, amount FROM transactions WHERE user_id = (?)`;

      db.query(query, [userid], async (err, result) => {
        if (err) {
          console.error("Error fetch database: ", err);
        }
        if (result.length === 0) {
          return res.status(404).json({ message: "Nodata" });
        } else {
          const paydetails = result.map((details) => ({
            ...details,
            date: moment(details.date).format("YYYY-MM-DD"),
          }));
          res.json(paydetails);
        }
      });
    }
  });
});

app.get("/getlocations", async (req, res) => {
  const query = `SELECT * FROM locations`;
  db.query(query, async (err, result) => {
    if (err) {
      console.error("Error fetch database");
    } else {
      const location = result.map((result) => result.locations);
      res.json(location);
    }
  });
});

app.get("/getlocationslatlang", async (req, res) => {
  const { destination } = req.query;

  if (!destination) {
    res.status(400).json({ message: "Destination required" });
    return;
  }

  const query = `SELECT latitude, longtitude FROM locations WHERE locations = ?`;
  db.query(query, [destination], async (err, result) => {
    if (err) {
      console.error("Error fetch database: ", err);
    } else {
      const location = result[0];
      res.json(location);
    }
  });
});

app.get("/getdetails", async (req, res) => {
  const { userid } = req.query;

  const query = `SELECT name, email, username FROM users WHERE user_id = (?)`;
  if (!userid) {
    return res.status(400).json({ message: "User ID required!" });
  }

  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      db.query(query, [userid], async (err, result) => {
        if (err) {
          console.error("Error fetch database: ", err);
        }
        if (result.length === 0) {
          return res.status(400).json({ message: "User not found" });
        } else {
          const dbdata = result[0];
          const { name, email, username } = dbdata;
          res.status(200).json({ name, email, username });
        }
      });
    }
  });
});

app.get("/viewtrip", async (req, res) => {
  const { userid } = req.query;

  if (!userid) {
    res.status(400).json({ message: "User ID required" });
    return;
  }
  const selectuserdb = `SELECT *  FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const query = `SELECT * FROM usertrips WHERE user_id = ?  ORDER BY date desc`;
      db.query(query, [userid], async (err, result) => {
        if (err) {
          console.error("Error fetch database: ", err);
        }
        if (result.length === 0) {
          return res.status(404).json({ message: "Nodata" });
        } else {
	const trip = result[0];
          res.json(trip);
        }
      });
    }
  });
});
app.post("/confirmseat", async (req, res) => {
  const { userid } = req.query;
  const { classes, price, seatrow, seatnumber, pickup, destination } = req.body;
  const refnum = randomstring.generate({ length: 8, charset: "numeric" });
  if (!userid) {
    return res.status(400).json({ message: "User ID required!" });
  }
if (!classes && !price && !seatrow && !seatnumber && !pickup && !destination) {
console.log("Details not found");
    return res.status(400).json({ message: "Deatils not found" });
  }


  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const referenceno = `ref${refnum}`;
      const storedb = `INSERT INTO usertrips VALUES(?, ?, ?, ?, ?, ?, ?, ?, TIMESTAMP(CURRENT_TIMESTAMP))`;
      db.query(
        storedb,
        [referenceno, userid, classes, price, seatrow, seatnumber, pickup, destination],
        async (err, save) => {
          if (err) {
            console.log("Error querying database: ", err);
            return res.status(500).json({ message: "Internal server error" });
          }
          if (save.length === 0) {
            return res.status(404).json({ message: "Confirmation failed" });
          } else {
            res.status(201).json({ message: "Confirmation success" });
          }
        }
      );
    }
  });
});

app.post("/login", async (req, res) => {
  const { username, password } = req.body;

  if (!username) {
    return res.status(400).json({ message: "Username required" });
  }
  if (!password) {
    return res.status(400).json({ message: "Password required" });
  }

  const query = `SELECT user_id AS userId, password FROM users WHERE username = ? OR email = ?`;

  db.query(query, [username, username], async (err, result) => {
    if (err) {
      console.error(err);
      res.status(500).json({ message: "Internal server error" });
      return;
    }

    if (result.length === 0) {
      res.status(404).json({ message: "User not found" });
      return;
    } else {
      const user = result[0];
      const { userId, password: hashedPassword } = user;
      bcrypt.compare(password, hashedPassword, (err, passwordMatch) => {
        if (err) {
          console.error(err);
          res.status(500).json({ message: "Internal server error" });
          return;
        }
        if (!passwordMatch) {
          res.status(400).json({ message: "Incorrect password" });
          return;
        } else {
          const token = jwt.sign({ userId }, JWT_SECRET, { expiresIn: 0 });
          res.json({ success: true, message: "Login Success", token });
        }
      });
    }
  });
});

app.post("/register", async (req, res) => {
  const { username, password, email, name } = req.body;
  if (!username) {
    res.status(400).json({ message: "Username is required" });
    return;
  }
  if (!password) {
    res.status(400).json({ message: "Password is required" });
    return;
  }
  if (!email) {
    res.status(400).json({ message: "Email is required" });
    return;
  }
  if (!name) {
    res.status(400).json({ message: "Name is required" });
    return;
  }
  if (!isValidUsername(username)) {
    return res.status(406).json({ message: "Invalid username format" });
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    res.status(406).json({ message: "Invalid email address" });
    return;
  }
  // Check if the username already exists
  const usernameQuery = "SELECT * FROM users WHERE username = ?";
  db.query(usernameQuery, [username], async (err, userResult) => {
    if (err) {
      console.error(err);
      res.status(500).json({ message: "Internal server error" });
    } else if (userResult.length > 0) {
      res.status(400).json({ message: "User already exists!" });
    } else {
      // Hash the password
      if (password.length >= 8) {
        const hashedPassword = await bcrypt.hash(password, 10);
        const uid = uuid.v4();

        const insertQuery =
          "INSERT INTO users (user_id, username, password, email, name) VALUES (?, ?, ?, ?, ?)";
        db.query(
          insertQuery,
          [uid, username, hashedPassword, email, name],
          (err, result) => {
            if (err) {
              console.error(err);
              res.status(500).json({ message: "Internal server error" });
            } else {
              res.status(200).json({ message: "User registered successfully" });
            }
          }
        );
      } else {
        console.error("Password minimum length is 8");
        res.status(411).json({ message: "Password minimum length is 8" });
      }
    }
  });
});

app.post("/changepassword", async (req, res) => {
  const { userid } = req.query;
  const { newpassword } = req.body;
  if (!userid) {
    return res.status(400).json({ message: "User ID required" });
  }
  if (!newpassword) {
    return res.status(400).json({ message: "New password is required" });
  }
  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const query = `SELECT password FROM users WHERE user_id = ?`;
      if (!userid) {
        res.status(400).json({ message: "User ID is required" });
        console.error("User ID is required");
        return;
      }
      db.query(query, [userid], async (err, result) => {
        if (err) {
          console.error("Error querying database: ", err);
          return res.status(500).json({ message: "Internal server error" });
        }
        if (result.length === 0) {
          console.error("User not found");
          return res.status(404).json({ message: "User not found" });
        }

        const user = result[0];
        const { password: hashedpass } = user;
        const passmatch = await bcrypt.compare(newpassword, hashedpass);
        if (passmatch) {
          console.error("Current password and New password is same!");
          return res.status(401).json({
            message: "Current password and New password is same!",
          });
        } else {
          if (newpassword.length >= 8) {
            const hashnewpass = await bcrypt.hash(newpassword, 10);

            const querycp = "UPDATE users SET password = ? WHERE user_id = ?";
            db.query(querycp, [hashnewpass, userid], (err, results) => {
              if (err) {
                console.error("Error updating password: ", err);
                return;
              }
              console.log("Password changed successfully");
              res
                .status(200)
                .json({ message: "Password changed successfully" });
            });
          } else {
            res.status(401).json({ message: "Password minimum length is 8" });
          }
        }
      });
    }
  });
});

app.post("/reportmissing", async (req, res) => {

 const { userid } = req.query;
  const missmessage = req.body.message;
  if (!userid) {
    res.status(400).json({ message: "User ID is required" });
    console.error("User ID is required");
    return;
  }

  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const query = `INSERT INTO missingtools VALUES (?, ?)`;
      db.query(query, [userid, missmessage], (err, result) => {
        if (err) {
          console.log("Internal server error: ", err);
          res.status(500).json({ message: "Internal Server Error" });
          return;
        }
        if (result.length === 0) {
          res.status(404).json({ message: "User data not found" });
          console.error("User data not found");
          return;
        } else {
	console.log(`User ${userid} reported a message ${missmessage}`);
          res.status(200).json({ message: "Reported successful" });
        }
      });
    }
  });


});

app.post("/changeuserdetails", async (req, res) => {
  const { userid } = req.query;
  const { name, email } = req.body;
  if (!userid) {
    res.status(400).json({ message: "User ID is required" });
    console.error("User ID is required");
    return;
  }
  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      if (name) {
        console.log("Changed requested name: ", name);
        const query = `UPDATE users SET name = ? WHERE user_id = ?`;
        db.query(query, [name, userid], async (err, result) => {
          if (err) {
            console.error("Internal server error: ", err);
            res.status(500).json({ message: "Internal Server Error" });
            return;
          }
          console.log("Name changed successfully");
          res.status(200).json({ message: "Name changed successfully" });
        });
      } else if (email) {
        const query = `UPDATE users SET email = ? WHERE user_id = ?`;
        db.query(query, [email, userid], async (err, result) => {
          if (err) {
            console.error("Internal server error: ", err);
            res.status(500).json({ message: "Internal Server Error" });
            return;
          }
          console.log("Email changed successfully");
          res.status(200).json({ message: "Email changed successfully" });
        });
      } else {
        return res.status(400).json({ message: "Email or Name required!" });
      }
    }
  });
});


app.post("/deleteaccount", async (req, res) => {
  const { userid } = req.query;

  if (!userid) {
    return res.status(400).json({ message: "User ID required!" });
  }

  const selectuserdb = `SELECT * FROM users WHERE user_id = ?`;
  db.query(selectuserdb, [userid], async (err, result) => {
    if (err) {
      console.log("Error querying database: ", err);
      return res.status(500).json({ message: "Internal server error" });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "User not found" });
    } else {
      const deletequery = `DELETE FROM users WHERE user_id = ?`;
      db.query(deletequery, [userid], async (err, result) => {
        if (err) {
          console.log("Error querying database: ", err);
          return res.status(500).json({ message: "Internal server error" });
        }
        if (result.length === 0) {
          return res.status(404).json({ message: "User not found" });
        } else {
          console.log("User deleted successfully");
          return res.status(200).json({ message: "User deleted" });
        }
      });
    }
  });
});

function isValidUsername(username) {
  const minLength = 5;
  const maxLength = 20;
  const allowedCharacters = /^[a-zA-Z0-9_-]+$/;
  if (username.length < minLength || username.length > maxLength) {
    return false;
  }
  if (!allowedCharacters.test(username)) {
    return false;
  }
  return true;
}


app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
