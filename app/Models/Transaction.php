<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model {
    protected $fillable = ['invoice_number', 'total_price', 'pay_amount', 'change_amount', 'payment_method'];

    public function details() {
        return $this->hasMany(TransactionDetail::class);
    }
}