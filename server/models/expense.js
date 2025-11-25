const mongoose = require("mongoose");

const ExpenseSchema = new mongoose.Schema({
	amount: {
		type: Number,
		required: true,
	},
	expenseType: {
		type: String,
		enum: ["Yakıt", "Yedek Parça", "Muhtelif", "Şahsi"],
		required: true,
	},
	date: {
		type: Date,
		required: true
	},
	description: {
		type: String,
	},
	phone: {
		//to understand which drivers' expenses they are
		type: String,
		required: true
	},
});

module.exports = Expense = mongoose.model("Expense", ExpenseSchema);
