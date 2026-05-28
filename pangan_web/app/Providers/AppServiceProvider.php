<?php

namespace App\Providers;

use Illuminate\Support\Facades\Blade;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Route::aliasMiddleware('role', \App\Http\Middleware\RoleMiddleware::class);

        Blade::if('role', function (string $roles) {
            if (! Auth::check()) {
                return false;
            }

            $user = Auth::user();
            $userRole = $user?->role ?? null;
            $acceptedRoles = array_map('trim', explode('|', $roles));

            return in_array($userRole, $acceptedRoles, true);
        });
    }
}
