FROM kasmweb/core-ubuntu-jammy:1.19.0-rolling-daily
USER root

ENV HOME       /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

## Configure single-application XFCE desktop and remove the panel
RUN cp "$HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/"* \
       "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/" \
    && apt-get remove -y xfce4-panel

## Base tools (Go + Python 3)
COPY shared/scripts/install_base_tools.sh $INST_SCRIPTS/shared/install_base_tools.sh
RUN bash "$INST_SCRIPTS/shared/install_base_tools.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

## GitHub CLI
COPY shared/scripts/install_gh.sh $INST_SCRIPTS/shared/install_gh.sh
RUN bash "$INST_SCRIPTS/shared/install_gh.sh" \
    && rm -rf "$INST_SCRIPTS/shared/"

## OpenAI Codex CLI
COPY images/codex/src/install_codex.sh $INST_SCRIPTS/codex/install_codex.sh
RUN bash "$INST_SCRIPTS/codex/install_codex.sh" \
    && rm -rf "$INST_SCRIPTS/codex/"

## Startup script
COPY images/codex/src/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod 755 "$STARTUPDIR/custom_startup.sh"

######### End Customizations ###########

RUN chown 1000:0 "$HOME"
RUN $STARTUPDIR/set_user_permission.sh "$HOME"

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p "$HOME" && chown -R 1000:0 "$HOME"

USER 1000
