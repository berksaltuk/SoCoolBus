const crypto = require("crypto").webcrypto;
/**
 * Generate a cryptographically secure random password.
 *
 * @returns {string}
 */
module.exports.password_generator = () => {
  const characterPool =
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._";
  const passwordLength = 8;
  const randomNumber = new Uint8Array(1);
  let password = "";

  for (let i = 0; i < passwordLength; i++) {
    do {
      crypto.getRandomValues(randomNumber);
    } while (randomNumber[0] >= characterPool.length);

    password += characterPool[randomNumber[0]];
  }

  return password;
};
