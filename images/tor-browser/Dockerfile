FROM kasmweb/core-ubuntu-jammy:1.19.0-rolling-daily
USER root

ENV HOME       /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

COPY shared/scripts/set_bg_black.sh $INST_SCRIPTS/shared/set_bg_black.sh
RUN cp "$HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/"* \
       "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/" \
    && apt-get remove -y xfce4-panel \
    && bash "$INST_SCRIPTS/shared/set_bg_black.sh" \
    && rm -f "$INST_SCRIPTS/shared/set_bg_black.sh"

COPY shared/scripts/install_base_tools.sh $INST_SCRIPTS/shared/install_base_tools.sh
RUN bash "$INST_SCRIPTS/shared/install_base_tools.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

COPY images/tor-browser/src/install_tor_browser.sh $INST_SCRIPTS/tor-browser/install_tor_browser.sh
RUN bash "$INST_SCRIPTS/tor-browser/install_tor_browser.sh" \
    && rm -rf "$INST_SCRIPTS/tor-browser/"

COPY images/tor-browser/src/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod 755 "$STARTUPDIR/custom_startup.sh"

RUN chown 1000:0 "$HOME"
RUN $STARTUPDIR/set_user_permission.sh "$HOME"

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p "$HOME" && chown -R 1000:0 "$HOME"

USER 1000
