FROM nginx
RUN mkdir -p /minecraft/maps
COPY . .
ENV RESTART_MIN=50000
ENV RESTART_MAX=100000
CMD cp -R /minecraft/maps/* /usr/share/nginx/html && \
	nginx && \
	sleep $(shuf -i $RESTART_MIN-$RESTART_MAX -n 1)
