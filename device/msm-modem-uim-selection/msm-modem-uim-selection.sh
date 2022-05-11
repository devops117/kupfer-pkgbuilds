#!/bin/bash

# taken from https://gitlab.com/postmarketOS/pmaports/-/blob/master/modem/msm-modem/msm-modem-uim-selection.initd

veinfo() {
  echo "INFO: $@"
}

ewarn() {
  echo "WARNING: $@"
}

eend() {
  echo "EXITING: rc $0: $@"
}


source /usr/lib/msm-modem-uim-selection/msm-modem-uim-selection.initd
start
