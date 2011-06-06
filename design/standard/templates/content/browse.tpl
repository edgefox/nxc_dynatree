{let item_type=ezpreference( 'admin_list_limit' )
     number_of_items=min( $item_type, 3)|choose( 10, 10, 25, 50 )
     browse_list_count=fetch( content, list_count, hash( parent_node_id, $node_id, depth, 1))
     node_array=fetch( content, list, hash( parent_node_id, $node_id, depth, 1, offset, $view_parameters.offset, limit, $number_of_items, sort_by, $main_node.sort_array ) )
     select_name='SelectedObjectIDArray'
     select_type='checkbox'
     select_attribute='contentobject_id'}



{section show=eq( $browse.return_type, 'NodeID' )}
    {set select_name='SelectedNodeIDArray'}
    {set select_attribute='node_id'}
{/section}

{section show=eq( $browse.selection, 'single' )}
    {set select_type='radio'}
{/section}

{section show=$browse.description_template}
    {include name=Description uri=$browse.description_template browse=$browse main_node=$main_node}
{section-else}


<div class="context-block">

{* DESIGN: Header START *}<div class="box-header"><div class="box-tc"><div class="box-ml"><div class="box-mr"><div class="box-tl"><div class="box-tr">

<h1 class="context-title">{'Browse'|i18n( 'design/admin/content/browse' )}</h1>

{* DESIGN: Mainline *}<div class="header-mainline"></div>

{* DESIGN: Header END *}</div></div></div></div></div></div>

{* DESIGN: Content START *}<div class="box-bc"><div class="box-ml"><div class="box-mr"><div class="box-bl"><div class="box-br"><div class="box-content">

<div class="block">

<p>{'To select objects, choose the appropriate radiobutton or checkbox(es), and click the "Choose" button.'|i18n( 'design/admin/content/browse' )}</p>
<p>{'To select an object that is a child of one of the displayed objects, click the object name and you will get a list of the children of the object.'|i18n( 'design/admin/content/browse' )}</p>

</div>

{* DESIGN: Content END *}</div></div></div></div></div></div>

</div>

{/section}

{if eq($select_type,'checkbox')}
	{def $select_mode = 2}
{else}
	{def $select_mode = 1}
{/if}

<div class="context-block">

<form name="browse" method="post" action={$browse.from_page|ezurl}>

{* DESIGN: Header START *}<div class="box-header"><div class="box-tc"><div class="box-ml"><div class="box-mr"><div class="box-tl"><div class="box-tr">

{let current_node=fetch( content, node, hash( node_id, $browse.start_node ) )}
{section show=$browse.start_node|gt( 1 )}
    <h2 class="context-title">
    <a href={concat( '/content/browse/', $main_node.parent_node_id, '/' )|ezurl}><img style="margin-top: -5px; padding-right: 3px; display: inline-block;" src={'admin/icons/folder_parent_small.gif'|ezimage} alt="{'Back'|i18n( 'design/admin/content/browse' )}" />{'Up level'|i18n('design/nxc_dynatree/base')}</a>
    &nbsp;{$current_node.name|wash}&nbsp;[{$current_node.children_count}]</h2>
{section-else}
    <h2 class="context-title"><img src={'back-button-16x16.gif'|ezimage} alt="Back" />&nbsp;{'Top level'|i18n( 'design/admin/content/browse' )}&nbsp;[{$current_node.children_count}]</h2>
{/section}
{/let}

{* DESIGN: Subline *}<div class="header-subline"></div>

{* DESIGN: Header END *}</div></div></div></div></div></div>

{* DESIGN: Content START *}<div class="box-ml"><div class="box-mr"><div class="box-content">

{* Items per page and view mode selector. *}
<div class="context-toolbar">
<div class="block">
<div class="left">

</div>
<div class="break"></div>
</div>
</div>
<script type="text/javascript">
{literal}
	var _activeKey = null;

  $(function(){

    $("#tree").ajaxComplete(function(event, XMLHttpRequest, ajaxOptions)
	{
        _log("debug", "ajaxComplete: %o", this);
    });

    $("#tree").dynatree(
	{
      checkbox: true,
	  persist: true,
      // Override class name for checkbox icon:
      classNames: {checkbox: "dynatree-{/literal}{$select_type}{literal}"},
      selectMode: {/literal}{$select_mode}{literal},
      //children: treeData,
      onPostInit: function(isReloading, isError) {
         logMsg("onPostInit(%o, %o) - %o", isReloading, isError, this);
         this.reactivate();
      },
	  fx: { height: "toggle", duration: 200 },
      initAjax: { url: {/literal}{'dynatree/getnodes/'|ezroot()}{literal},
             	  dataType: "json",
             	  data: { key: {/literal}"{$node_id}"{literal},
						  Status: "init",
						  BrowseObject: {/literal}{json_encode($browse)}{literal},
						  Mode: "{/literal}{$select_name}{literal}"
						}
      },
      onLazyRead: function(node){
        node.appendAjax(
        { url: {/literal}{'arkiv/getnodes/'|ezroot()}{literal},
          dataType: "json", // Enable JSONP, so this sample can be run from the local file system against a localhost server
          data: { key: node.data.key,
              	  Status: "getChild",
				  BrowseObject: {/literal}{json_encode($browse)}{literal},
				  Mode: "{/literal}{$select_name}{literal}"
             	}
        });
	  },
      onDblClick: function(node, event) {
        node.toggleSelect();
      },
      onKeydown: function(node, event) {
        if( event.which == 32 ) {
          node.toggleSelect();
          return false;
        }
      }
    });

	$("form[name=browse]").submit(function() {
	  var selectedObject = $('#tree').dynatree("getSelectedNodes");
	  var selectedString = selectedObject.toString();
	  if ( selectedString.length > 0 )
	  {
		  var re = /[0-9]+/g;
		  var selectedArray = selectedString.match(re);

		  if (selectedArray.length > 1)
		  {
			$('#hiddens').find('input').remove();
			for (i = 0; i < selectedArray.length; i++)
			{
				$('#hiddens').append("<input type='hidden' name='{/literal}{$select_name}{literal}[]' value='"+selectedArray[i]+"' />");
			}
		  }
		  else
			$('#hiddens').append("<input type='hidden' name='{/literal}{$select_name}{literal}[]' value='"+selectedArray[0]+"' />");
	  }

	  return true;
    });

});
	</script>
{/literal}

 <div id="tree"></div>

{section var=PersistentData show=$browse.persistent_data loop=$browse.persistent_data}
    <input type="hidden" name="{$PersistentData.key|wash}" value="{$PersistentData.item|wash}" />
{/section}

<input type="hidden" name="BrowseActionName" value="{$browse.action_name}" />
{section show=$browse.browse_custom_action}
    <input type="hidden" name="{$browse.browse_custom_action.name}" value="{$browse.browse_custom_action.value}" />
{/section}

{section show=$cancel_action}
<input type="hidden" name="BrowseCancelURI" value="{$cancel_action}" />
{/section}

{* DESIGN: Content END *}</div></div></div>

<div class="controlbar">
{* DESIGN: Control bar START *}<div class="box-bc"><div class="box-ml"><div class="box-mr"><div class="box-tc"><div class="box-bl"><div class="box-br">
<div class="block">
    <input class="button" type="submit" name="SelectButton" value="{'OK'|i18n( 'design/admin/content/browse' )}" />
    <input class="button" type="submit" name="BrowseCancelButton" value="{'Cancel'|i18n( 'design/admin/content/browse' )}" />
</div>
{* DESIGN: Control bar END *}</div></div></div></div></div></div>
</div>

<div id="hiddens">
</div>

</form>

{/let}

</div>
