FROM centos:latest
LABEL maintainer="marc@webmarcit.com"
RUN yum -y update
RUN yum -y install epel-release
RUN yum-config-manager --add-repo https://copr.fedorainfracloud.org/coprs/g/spacewalkproject/spacewalk-2.7/repo/epel-7/group_spacewalkproject-spacewalk-2.7-epel-7.repo
RUN yum -y install expect
RUN yum -y install rhnpush
RUN yum -y install rpm-build
RUN yum -y install rpm-sign
RUN yum -y install rpmdevtools
RUN yum -y install yum-utils
# Confirm that the EPEL repo has been added
# A line simliar should follow
# epel Extra Packages for Enterprise Linux 6 - x86_64
CMD yum repolist
