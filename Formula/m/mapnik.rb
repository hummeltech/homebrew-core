class Mapnik < Formula
  desc "Toolkit for developing mapping applications"
  homepage "https://mapnik.org/"
  license "LGPL-2.1-or-later"
  revision 24
  head "https://github.com/mapnik/mapnik.git", branch: "master"

  # TODO: Try switching to CMake build on next release as it works better with
  # Homebrew's build environment.
  stable do
    url "https://github.com/mapnik/mapnik/releases/download/v3.1.0/mapnik-v3.1.0.tar.bz2"
    sha256 "43d76182d2a975212b4ad11524c74e577576c11039fdab5286b828397d8e6261"

    # Fix build with bundled SCons. Remove in the next release.
    # Ref: https://github.com/mapnik/mapnik/pull/4294
    patch do
      url "https://github.com/mapnik/mapnik/commit/7da9009e7ffffb0b9429890f6f13fee837ac320f.patch?full_index=1"
      sha256 "eef9ab6327590a2ee295af03b40d7cfb381dbe35441914230880b0f764574e43"
    end

    # Fix build with Boost v1.83 using Arch Linux patch. Remove in the next release.
    # Ref: https://github.com/mapnik/mapnik/pull/4413
    patch do
      url "https://github.com/mapnik/mapnik/commit/26eb76cc07210d564d80d98948770c94d27c5243.patch?full_index=1"
      sha256 "085408d6a38c77df7f333047bb1568bf0dfdf9c3b87fd9001997ba9b22be6d4c"
    end
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "a0a1b6360c0cece81b347399035adf72c37aaa8a0571429e187e3164a96a6666"
    sha256 cellar: :any,                 arm64_ventura:  "b2019d903eff1a8bde945fcb9b088b095b2c5a5b4f091a96a85d7a0f9fa008c0"
    sha256 cellar: :any,                 arm64_monterey: "cc89afb86d3575a249a597befceecdc09b2362b7b8e2151b2175fc7b7d17d6de"
    sha256 cellar: :any,                 sonoma:         "68235c5ce9297306713dbb7c71066956de420a0229019b9764a73814cfd59805"
    sha256 cellar: :any,                 ventura:        "6bf46176062aeba1a4ed2acedc146a4722710a9973730fd90bde2b37bf5aa59c"
    sha256 cellar: :any,                 monterey:       "6f045a71e924bca05c295e7f3116005a1dba0ee5b62664bc4dc093ca125f4a6b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d1cc2990f23e96b662d3c342992368c295f464914c77af26668f1c13e461f428"
  end

  depends_on "pkg-config" => :build
  depends_on "python@3.11" => :build
  depends_on "boost"
  depends_on "cairo"
  depends_on "freetype"
  depends_on "gdal"
  depends_on "harfbuzz"
  depends_on "icu4c"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libpq"
  depends_on "libtiff"
  depends_on "libxml2"
  depends_on "proj"
  depends_on "sqlite"
  depends_on "webp"

  uses_from_macos "zlib"

  def install
    boost = Formula["boost"]
    harfbuzz = Formula["harfbuzz"]
    icu = Formula["icu4c"]
    jpeg = Formula["jpeg-turbo"]
    libpng = Formula["libpng"]
    libpq = Formula["libpq"]
    libtiff = Formula["libtiff"]
    proj = Formula["proj"]
    sqlite = Formula["sqlite"]
    webp = Formula["webp"]

    # upstream issue, see https://github.com/boostorg/phoenix/issues/115
    # workaround to avoid the inclusion of `boost/phoenix/stl/tuple.hpp`
    ENV.append "CXXFLAGS", "-DBOOST_PHOENIX_STL_TUPLE_H_"

    if OS.linux?
      deps.map(&:to_formula).select(&:keg_only?).map(&:opt_lib).each do |libdir|
        ENV.append "LDFLAGS", "-Wl,-rpath,#{libdir}"
      end
      ENV.append "LDFLAGS", "-Wl,-rpath,#{HOMEBREW_PREFIX}/lib"
    end

    args = %W[
      CC=#{ENV.cc}
      CXX=#{ENV.cxx}
      CUSTOM_CFLAGS=#{ENV.cflags}
      CUSTOM_CXXFLAGS=#{ENV.cxxflags}
      CUSTOM_LDFLAGS=#{ENV.ldflags}
      PREFIX=#{prefix}
      FAST=True
      CPP_TESTS=False
      INPUT_PLUGINS=all
      XMLPARSER=libxml2
      BOOST_INCLUDES=#{boost.opt_include}
      BOOST_LIBS=#{boost.opt_lib}
      FREETYPE_CONFIG=#{Formula["freetype"].opt_bin}/freetype-config
      GDAL_CONFIG=#{Formula["gdal"].opt_bin}/gdal-config
      HB_INCLUDES=#{harfbuzz.opt_include}
      HB_LIBS=#{harfbuzz.opt_lib}
      ICU_INCLUDES=#{icu.opt_include}
      ICU_LIBS=#{icu.opt_lib}
      JPEG_INCLUDES=#{jpeg.opt_include}
      JPEG_LIBS=#{jpeg.opt_lib}
      PG_CONFIG=#{libpq.opt_bin}/pg_config
      PNG_INCLUDES=#{libpng.opt_include}
      PNG_LIBS=#{libpng.opt_lib}
      PROJ_INCLUDES=#{proj.opt_include}
      PROJ_LIBS=#{proj.opt_lib}
      SQLITE_INCLUDES=#{sqlite.opt_include}
      SQLITE_LIBS=#{sqlite.opt_lib}
      TIFF_INCLUDES=#{libtiff.opt_include}
      TIFF_LIBS=#{libtiff.opt_lib}
      WEBP_INCLUDES=#{webp.opt_include}
      WEBP_LIBS=#{webp.opt_lib}
    ]

    system "python3", "scons/scons.py", "configure", *args
    system "python3", "scons/scons.py", "install", "--jobs=#{ENV.make_jobs}"
  end

  test do
    output = shell_output("#{bin}/mapnik-config --prefix").chomp
    assert_equal prefix.to_s, output
  end
end
