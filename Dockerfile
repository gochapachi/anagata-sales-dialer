# Stage 1: Build the Flutter Android APK
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

WORKDIR /app

# Copy all source files
COPY . .

# Scaffold missing platform wrappers and build release APK
RUN flutter create . --org in.anagataitsolutions --project-name anagata_sales_dialer
RUN flutter pub get
RUN flutter build apk --release

# Stage 2: Serve the compiled APK via Nginx
FROM nginx:alpine

# Copy the compiled APK to Nginx webroot
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html/anagata-dialer.apk

# Modern mobile download portal
RUN echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Anagata Sales Dialer</title><style>body{font-family:system-ui,-apple-system,sans-serif;background:#0f172a;color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:20px;text-align:center;}.card{background:#1e293b;padding:40px;border-radius:16px;max-width:440px;box-shadow:0 10px 25px rgba(0,0,0,0.5);border:1px solid #334155;}h1{color:#818cf8;margin-top:0;font-size:24px;}p{color:#94a3b8;font-size:14px;line-height:1.6;}a.btn{display:inline-block;background:#4f46e5;color:#fff;font-weight:600;padding:14px 28px;border-radius:10px;text-decoration:none;margin-top:20px;transition:background 0.2s;}a.btn:hover{background:#4338ca;}.badge{display:inline-block;background:#064e3b;color:#34d399;padding:4px 10px;border-radius:20px;font-size:12px;font-weight:bold;margin-bottom:15px;}</style></head><body><div class="card"><div class="badge">v1.0.0 Release</div><h1>Anagata Sales Dialer</h1><p>Zero-VoIP SIM Sales Dialer and Call Recording Synchronizer for Anagata IT Solutions & Odoo 18 CRM.</p><a class="btn" href="/anagata-dialer.apk" download>⬇️ Download APK</a></div></body></html>' > /usr/share/nginx/html/index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
