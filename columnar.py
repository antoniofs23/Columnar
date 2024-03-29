import os
import signal
import subprocess

# to avoid warnings and code crashes first import gi
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gst", "1.0")
gi.require_version("AppIndicator3", "0.1")
gi.require_version("Notify", "0.7")

from gi.repository import Gtk as gtk
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Notify as notify


APPINDICATOR_ID = "myappindicator"

# change the working directory when script is run through command-line
abspath = os.path.abspath(__file__)
dirname = os.path.dirname(abspath)
os.chdir(dirname)

# run the script
subprocess.call("./winManage.sh &", shell=True)


def main():
    indicator = appindicator.Indicator.new(
        APPINDICATOR_ID,
        os.path.abspath("columnar.svg"),
        appindicator.IndicatorCategory.SYSTEM_SERVICES,
    )
    indicator.set_status(appindicator.IndicatorStatus.ACTIVE)
    indicator.set_menu(build_menu())
    notify.init(APPINDICATOR_ID)
    gtk.main()


def build_menu():
    menu = gtk.Menu()
    menu.show_all()
    return menu


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()
