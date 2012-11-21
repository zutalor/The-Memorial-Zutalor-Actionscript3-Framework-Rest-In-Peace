package com.zutalor.view.utils
{
    import com.asual.swfaddress.SWFAddress;
    import com.zutalor.fx.Transition;
    import com.zutalor.fx.TransitionTypes;
    import com.zutalor.objectPool.ObjectPool;
    import com.zutalor.properties.ApplicationProperties;
    import com.zutalor.properties.MediaProperties;
	import com.zutalor.properties.ViewProperties;
    import com.zutalor.propertyManagers.Presets
    import com.zutalor.properties.TransitionProperties;
    import com.zutalor.propertyManagers.Props;
    import com.zutalor.utils.Logger;
	import com.zutalor.utils.ShowError;
	import com.zutalor.utils.StageRef;
    import flash.events.EventDispatcher;
    /**
     * ...
     * @author Geoff Pepos
     */
    public class ViewCloser
    {
        private var ap:ApplicationProperties;
        private var pr:Presets;
        private var _vp:ViewProperties;
        private var _onComplete:Function;
        private var _transition:Transition;

        public function ViewCloser()
        {
            ap = ApplicationProperties.gi();
            pr = Presets.gi();
        }

        public function close(viewId:String, onComplete:Function = null):void
        {
			_vp = Props.views.getPropsById(viewId);
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
            var tpp:TransitionProperties;
            var mpp:MediaProperties;
			
            _vp.container.stop(_vp.mediaPreset);
            if (_vp.transitionPreset)
            {
                tpp = pr.transitionPresets.getPropsByName(_vp.transitionPreset);
                if (tpp)
                {
                    _transition = ObjectPool.getTransition();
                    _transition.render(_vp.container, tpp.outType, tpp.outEase, tpp.outTime, tpp.outDelay, 
												TransitionTypes.OUT, tpp.xValue, tpp.yValue, resetContainer);
                }
                else
                {
                    _vp.container.visible = false;
                    resetContainer();
                }
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