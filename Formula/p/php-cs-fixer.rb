class PhpCsFixer < Formula
  desc "Tool to automatically fix PHP coding standards issues"
  homepage "https://cs.symfony.com/"
  url "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/download/v3.36.0/php-cs-fixer.phar"
  sha256 "5f3cf0fe008789113f5540d6df5137cc0d83ede5017a3cc0b5dd5919f5c76515"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, sonoma:         "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, ventura:        "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, monterey:       "db4a537fb3399833b2391049ebcbb3ec4ec6dfab3d7ac803d98eb9a30db9dad9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "6475424953f0cae61196e7f6a2079325064a55951094de04d9ff7d0c80c9e08f"
  end

  depends_on "php"

  def install
    libexec.install "php-cs-fixer.phar"

    (bin/"php-cs-fixer").write <<~EOS
      #!#{Formula["php"].opt_bin}/php
      <?php require '#{libexec}/php-cs-fixer.phar';
    EOS
  end

  test do
    (testpath/"test.php").write <<~EOS
      <?php $this->foo(   'homebrew rox'   );
    EOS
    (testpath/"correct_test.php").write <<~EOS
      <?php

      $this->foo('homebrew rox');
    EOS

    system bin/"php-cs-fixer", "fix", "test.php"
    assert compare_file("test.php", "correct_test.php")
  end
end
