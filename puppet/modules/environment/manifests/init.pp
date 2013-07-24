class environment {
    package { 'vim-enhanced':                                                                                                               
        ensure => installed
    }

    package { 'lsof':
        ensure => installed
    }
    
    package { 'htop':
        ensure => installed
    }
}
