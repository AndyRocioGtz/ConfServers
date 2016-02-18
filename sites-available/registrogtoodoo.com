upstream registro.odoo.la{
   server localhost:8069 weight=1 max_fails=3 fail_timeout=30m;
}
server {
   listen 80;
   server_name registro.odoo.la;
   access_log /var/log/nginx/registro-access-http.log;
   error_log /var/log/nginx/registro-error-http.log;
   location / {
       proxy_pass http://registro.odoo.la;
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
       proxy_redirect off;
       error_page 502 = /50x.html;
   }
   location ~* /web/static {
       proxy_cache_valid 200 60m;
       send_timeout 200m;
       proxy_read_timeout 200m;
       proxy_connect_timeout 200m;
       proxy_buffering on;
       expires 864000;
       proxy_pass http://registro.odoo.la;
   }
   location = /50x.html {
       root /usr/share/nginx/html;
   }
}

