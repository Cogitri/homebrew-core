class Libadwaita < Formula
  desc "Building blocks for modern GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/doc/"
  url "https://gitlab.gnome.org/GNOME/libadwaita/-/archive/1.0.0-alpha.1/libadwaita-1.0.0-alpha.1.tar.gz"
  sha256 "15b99dd4116bd0d8c6e98b2ec8867a254cd109d96c112096cf90a8cd5b764e24"
  license "LGPL-2.1-or-later"

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "sassc" => :build
  depends_on "vala" => :build
  depends_on "gtk4"

  def install
    args = std_meson_args + %w[
      -Dtests=false
    ]

    ENV["DESTDIR"] = "/"
    mkdir "build" do
      system "meson", *args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <gtk/gtk.h>
      #include <adwaita.h>

      static void
      startup (GtkApplication *app)
      {
        adw_init ();
      }

      int
      main (int    argc,
            char **argv)
      {
        GtkApplication *app;
        int status;

        app = gtk_application_new ("com.github.HomeBrew.homebrew-core.adwaita-tests", G_APPLICATION_FLAGS_NONE);
        g_signal_connect (app, "startup", G_CALLBACK (startup), NULL);
        status = g_application_run (G_APPLICATION (app), argc, argv);
        g_object_unref (app);

        return status;
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
