FROM opamp/archlinux:latest
MAINTAINER opamp_sando <opampg@gmail.com>

RUN echo 'Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -S sbcl libev gcc --noconfirm
USER user
WORKDIR /home/user

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp
RUN sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)' --quit
ADD sbclrc /home/user/.sbclrc

ADD project /home/user/quicklisp/local-projects/kanekanekane
RUN sudo chown -R user:users /home/user/quicklisp/local-projects/kanekanekane /home/user/.sbclrc

CMD ["sbcl", "--eval", "(ql:quickload :kanekanekane)", "--eval", "(kanekanekane:start :server :woo :port 8080)"]
