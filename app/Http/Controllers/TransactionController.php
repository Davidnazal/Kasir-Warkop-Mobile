<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $date = $request->query('date', now()->format('Y-m-d'));

        $transactions = Transaction::with('details.product')
            ->whereDate('created_at', $date)
            ->latest('id')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $transactions,
        ], 200);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'pay_amount' => 'required|numeric',
            'payment_method' => 'required|in:cash,qris',
        ]);

        return DB::transaction(function () use ($request): JsonResponse {
            $totalPrice = 0;
            $itemsToInsert = [];

            foreach ($request->items as $item) {
                $product = Product::findOrFail($item['product_id']);

                if ($product->stock < $item['quantity']) {
                    return response()->json([
                        'message' => "Stok {$product->name} tidak cukup!",
                    ], 400);
                }

                $subtotal = $product->price * $item['quantity'];
                $totalPrice += $subtotal;

                // Pengurangan Stok Otomatis
                $product->decrement('stock', $item['quantity']);

                $itemsToInsert[] = [
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price,
                    'subtotal' => $subtotal,
                ];
            }

            if ($request->pay_amount < $totalPrice) {
                return response()->json(['message' => 'Uang pembayaran kurang!'], 400);
            }

            $transaction = Transaction::create([
                'invoice_number' => 'INV-'.time().'-'.rand(100, 999),
                'total_price' => $totalPrice,
                'pay_amount' => $request->pay_amount,
                'change_amount' => $request->pay_amount - $totalPrice,
                'payment_method' => $request->payment_method,
            ]);

            foreach ($itemsToInsert as $detail) {
                $transaction->details()->create($detail);
            }

            return response()->json([
                'message' => 'Transaksi berhasil diproses',
                'data' => $transaction->load('details.product'),
            ], 201);
        });
    }

    public function reports(): JsonResponse
    {
        $today = now()->format('Y-m-d');
        $transactions = Transaction::with('details.product')
            ->whereDate('created_at', $today)
            ->latest('id')
            ->get();

        return response()->json([
            'date' => $today,
            'total_omset' => (int) $transactions->sum('total_price'),
            'total_transactions' => $transactions->count(),
            'transactions' => $transactions,
        ], 200);
    }
}
