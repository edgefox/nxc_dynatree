<?php

/* DEFINITION OF AVAILABLE MODES
 */
define('INIT','init');
define('GET_CHILDREN','getChildren');

$http = eZHTTPTool::instance();

if ($http->hasVariable('key') && $http->hasVariable('BrowseObject') && $http->hasVariable('Mode') && $http->hasVariable('Status'))
{

	if ($http->variable('Status') == 'SelectedObjectIDArray')
		$objectMode = true;
	else
		$objectMode = false;

	$browse = $http->variable('BrowseObject');

	if ( ($http->variable('Mode') == INIT && $objectMode) || !$objectMode )
	{
		$node = eZContentObjectTreeNode::fetch($http->variable('key'));
		$children = $node->children();
	}
	else
	{
		$node = eZContentObject::fetch($http->variable('key'));
		$mainNode = $node->attribute('main_node');
		$nodeID = $mainNode->attribute('node_id');

		$treeNode = eZContentObjectTreeNode::fetch($nodeID);
		$children = $treeNode->children();
	}

	$response = array();
	$offset = 0;

	foreach($children as $key => $child)
	{
		if (!$objectMode)
		{
			$keyID = $child->attribute('node_id');
		}
		else
		{
			$object = $child->attribute('object');
			$keyID = $object->attribute('id');
		}

		$ignore_nodes = array_merge($browse['Parameters']['ignore_nodes_select_subtree'],$child->attribute('path_array'));

		if ( (!$browse['Parameters']['permission'] || ($child->canRead())) && !in_array($child->attribute('node_id'),$browse['Parameters']['ignore_nodes_select']) && count($ignore_nodes) == count(array_unique($ignore_nodes)) )
		{
			if ( is_array($browse['Parameters']['class_array']) )
			{
				if ( in_array($child->attribute('class_identifier'),$browse['Parameters']['class_array']) )
				{
					$response[$key-$offset]['title'] = $child->attribute('name');
					$response[$key-$offset]['key'] = $keyID;
					$response[$key-$offset]['isFolder'] = ($child->attribute('is_container')) ? true : false;
					$response[$key-$offset]['unselectable'] = ($child->attribute('is_container')) ? false : true;
					$response[$key-$offset]['isLazy'] = ($child->attribute('is_container') && $child->childrenCount()) ? true : false;
				}
				else
				{
					$offset++;
					continue;
				}
			}
			else
			{
				if ( ( $browse['Parameters']['action_name'] == 'MoveNode' || $browse['Parameters']['action_name'] == 'CopyNode' ) && !$child->attribute('is_container') )
				{
					$response[$key-$offset]['title'] = $child->attribute('name');
					$response[$key-$offset]['key'] = $keyID;
					$response[$key-$offset]['isFolder'] = false;
					$response[$key-$offset]['unselectable'] = true;
					$response[$key-$offset]['isLazy'] = false;
				}
				else
				{
					$response[$key-$offset]['title'] = $child->attribute('name');
					$response[$key-$offset]['key'] = $keyID;
					$response[$key-$offset]['isFolder'] = ($child->attribute('is_container')) ? true : false;
					$response[$key-$offset]['unselectable'] = false;
					$response[$key-$offset]['isLazy'] = ($child->attribute('is_container') && $child->childrenCount()) ? true : false;
				}
			}
		}
		else
		{
			$offset++;
			continue;
		}
	}

	echo json_encode($response);
}

eZExecution::cleanExit();

?>
