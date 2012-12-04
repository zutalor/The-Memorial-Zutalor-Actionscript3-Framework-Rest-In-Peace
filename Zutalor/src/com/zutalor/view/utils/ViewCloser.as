package com.zutalor.view.utils
{
	import com.zutalor.fx.Transition;
	import com.zutalor.fx.TransitionTypes;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.properties.MediaProperties;
	import com.zutalor.view.properties.ViewProperties;
	import com.zutalor.propertyManagers.Presets;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
	import com.zutalor.view.controller.ViewController;
	import com.zutalor.view.properties.ViewProperties;
    /**
     * ...
     * @author Geoff Pepos
     */
    public class ViewCloser
    {
        private var ap:ApplicationProperties;
        private var pr:*;
        private var _vp:ViewProperties;
        private var _onComplete:Function;
        private var _transition:Transition;

        public function ViewCloser()
        {
            ap = ApplicationProperties.gi();
            pr = Presets;
        }

        public function close(viewId:String, onComplete:Function = null):void
        {
			_vp = ViewController.views.getPropsById(viewId);
            _onComplete = onComplete;

            if (!_vp)
                ShowError.fail(ViewCloser,"View Closer: '" + viewId + "' is not a valid view name.");
            else
            {
                if (_vp.container.visible)
                    doTransition();
                else
                    resetContainer();
            }
        }

        private function doTransition():void
        {
            var mpp:MediaProperties;
			
            _vp.container.stop();
            if (_vp.transitionPreset)
            {
				_transition = ObjectPool.getTransition();
                _transition.simpleRender(_vp.container, _vp.transitionPreset, TransitionTypes.OUT, resetContainer);
            }
            else
            {
                _vp.container.visible = false;
                resetContainer();
            }
        }

        private function resetContainer():void
        {
			StageRef.stage.removeChild(_vp.container);
			_vp.container.recycle();
            if (_onComplete != null)
                _onComplete();
        }
    }
}