FROM opamp/archlinux:latest
MAINTAINER opamp_sando <opampg@gmail.com>

WORKDIR /
RUN echo 'Server = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN pacman -S libev git base-devel --noconfirm --needed

USER user
WORKDIR /home/user

# install roswell
RUN curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/roswell.tar.gz
RUN tar xfz roswell.tar.gz &&rm -f roswell.tar.gz
WORKDIR /home/user/roswell
RUN makepkg && sudo pacman -U *.pkg.tar.zst --noconfirm
WORKDIR /home/user
RUN rm -fr roswell

# roswell setup
RUN ros install sbcl-bin
RUN ros use sbcl-bin
RUN ros install t-sin/ros-tap
RUN ros install clack
ENV PATH $PATH:/home/user/.roswell/bin

# install kanekanekane
RUN git clone https://github.com/opamp/kanekanekane.git
WORKDIR /home/user/kanekanekane
RUN rm -f src/config.lisp run.sh
ADD config.lisp /home/user/kanekanekane/src/config.lisp
ADD run.sh /home/user/kanekanekane/run.sh

# taptap
RUN ros tap tap kanekanekane.asd

CMD ["./run.sh"]
