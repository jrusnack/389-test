class directory {
    case $operatingsystem {
        centos, redhat, fedora: {
            notify { 'Running on supported OS': }
        }
        default: { fail("Unsupported operating system") }
    }

    package { '389-ds-base':
        ensure => installed
    }
}

