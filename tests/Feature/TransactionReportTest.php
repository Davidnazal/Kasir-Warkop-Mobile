<?php

namespace Tests\Feature;

use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransactionReportTest extends TestCase
{
    use RefreshDatabase;

    public function test_reports_and_transactions_include_ordered_items(): void
    {
        $coffee = Product::create([
            'name' => 'Kopi Susu Aren',
            'price' => 18000,
            'stock' => 20,
        ]);
        $noodle = Product::create([
            'name' => 'Indomie Special Telur',
            'price' => 16000,
            'stock' => 10,
        ]);

        $storeResponse = $this->postJson('/api/transactions', [
            'items' => [
                ['product_id' => $coffee->id, 'quantity' => 2],
                ['product_id' => $noodle->id, 'quantity' => 1],
            ],
            'pay_amount' => 60000,
            'payment_method' => 'cash',
        ]);

        $storeResponse->assertStatus(201)
            ->assertJsonPath('data.total_price', 52000)
            ->assertJsonCount(2, 'data.details');

        $transactionsResponse = $this->getJson('/api/transactions');
        $transactionsResponse->assertStatus(200)
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.details.0.product.name', 'Kopi Susu Aren')
            ->assertJsonPath('data.0.details.0.quantity', 2);

        $reportsResponse = $this->getJson('/api/reports');
        $reportsResponse->assertStatus(200)
            ->assertJsonPath('total_omset', 52000)
            ->assertJsonPath('total_transactions', 1)
            ->assertJsonCount(1, 'transactions')
            ->assertJsonPath('transactions.0.details.1.product.name', 'Indomie Special Telur');
    }
}
