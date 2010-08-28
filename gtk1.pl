use Data::Dumper;
use Gtk2 '-init';
use Gtk2::SimpleList;

use constant TRUE  => 1;
use constant FALSE => 0;

$window = Gtk2::Window->new('toplevel');
#$window = Gtk2::Window->new;
$window->set_title ('SimpleList examples');
$window->signal_connect (delete_event => sub {Gtk2->main_quit; TRUE});

$window->set_border_width(10);

$box1 = Gtk2::HBox->new(FALSE, 0);
$vbox = Gtk2::VBox->new(FALSE, 0);
$window->add($box1);

$buttonS = Gtk2::Button->new("Spam");
$buttonF = Gtk2::Button->new("Friend");
$buttonI = Gtk2::Button->new("Ignore");

$label = Gtk2::Label->new("hello GTK");

$vbox->add($label);
$vbox->add($box1);
$box1->add($buttonS);
$box1->add($buttonF);
$box1->add($buttonI);

$buttonS->show;
$buttonF->show;
$buttonI->show;
$label->show;
$vbox->show;
$box1->show;

$window->show;


Gtk2->main;

#sleep 10;


