<?php

$Module = array( 'name' => 'dynatree',
                 'variable_params' => true );

$ViewList = array();

$ViewList['getnodes'] = array(
    'script' => 'getnodes.php',
    'default_action' => array(),
    'single_post_actions' => array(),
    'post_action_parameters' => array('key','Status','Mode','BrowseObject'));

?>
