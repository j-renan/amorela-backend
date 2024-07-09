<?php

use App\Http\Controllers\Api\AuthController;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json('amorela API ok', 200);
});

Route::get('/user', function (Request $request) {
    $userId = $request->userId;
    $user = User::find($userId);
    return response()->json($user, 200);
})->middleware('auth:sanctum');

Route::post('/tokens/create', function (Request $request) {
    $userId = $request->userId;
    $user = User::find($userId);
    $user->createToken($request->token_name);
    $token = $request->user()->createToken($request->token_name);

    return ['token' => $token->plainTextToken];
});

Route::post('/login', function (Request $request) {

    # do any validations here

    $user = User::where('email', $request->email)->first();
    $token = $user->createToken("The user agent here");

    return ['token' => $token->plainTextToken];
});

Route::controller(AuthController::class)->group(function() {
    Route::post('/auth/register','createUser');
    Route::post('/auth/login', 'loginUser');
});

