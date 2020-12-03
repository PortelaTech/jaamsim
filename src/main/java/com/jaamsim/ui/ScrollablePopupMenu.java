/*
 * JaamSim Discrete Event Simulation
 * Copyright (C) 2018-2020 JaamSim Software Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.jaamsim.ui;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Insets;
import java.awt.LayoutManager;
import java.awt.Rectangle;
import java.awt.event.AdjustmentEvent;
import java.awt.event.AdjustmentListener;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

import javax.swing.JPopupMenu;
import javax.swing.JScrollBar;

public class ScrollablePopupMenu extends JPopupMenu {

	private static final int MAX_ROWS = 10;
	private JScrollBar scrollBar;

	public ScrollablePopupMenu() {
		this(null);
	}

	public ScrollablePopupMenu(String label) {
		super(label);

		// First component is the scroll bar
		scrollBar = new JScrollBar();
		scrollBar.setVisible(false);
		scrollBar.addAdjustmentListener(new AdjustmentListener() {
			@Override
			public void adjustmentValueChanged(AdjustmentEvent e) {
				doLayout();
				repaint();
			}
		});
		super.add(scrollBar);

		// Use a customised LayoutManager to position the scroll bar correctly
		setLayout(new ScrollableMenuLayout());

		// Respond to the mouse wheel
		addMouseWheelListener(new MouseWheelListener() {
			@Override
			public void mouseWheelMoved(MouseWheelEvent event) {
				int amount = (event.getScrollType() == MouseWheelEvent.WHEEL_UNIT_SCROLL)
						? event.getUnitsToScroll() * scrollBar.getUnitIncrement()
						: (event.getWheelRotation() < 0 ? -1 : 1) * scrollBar.getBlockIncrement();

				scrollBar.setValue(scrollBar.getValue() + amount);
				event.consume();
			}
		});
	}

	@Override
	protected void addImpl(Component comp, Object constraints, int index) {
		super.addImpl(comp, constraints, index);

		if (getComponentCount() > MAX_ROWS + 1) {
			scrollBar.setVisible(true);
		}
	}

	@Override
	public void show(Component invoker, int x, int y) {
		if (scrollBar.isVisible()) {
			int extent = ScrollableMenuLayout.getExtent(this, MAX_ROWS);
			Dimension size = ScrollableMenuLayout.getSize(this);
			int width = size.width;
			int max = size.height;
			Insets insets = getInsets();

			scrollBar.setUnitIncrement(ScrollableMenuLayout.getComponentHeight(this));
			scrollBar.setBlockIncrement(extent);
			scrollBar.setValues(
					0,
					extent + insets.top + insets.bottom,
					0,
					max + insets.top + insets.bottom);

			setPopupSize(new Dimension(
					width + scrollBar.getPreferredSize().width + insets.left + insets.right,
					extent + insets.top + insets.bottom));
		}

		super.show(invoker, x, y);
	}

	public void ensureIndexIsVisible(int index) {
		Rectangle rect = getComponent(index + 1).getBounds();  // scrollBar is the first component
		rect.y += scrollBar.getValue();
		scrollBar.scrollRectToVisible(rect);
	}

	@Override
	public void scrollRectToVisible(Rectangle rect) {

		// ScrollBar values for the top and bottom of the rectangle
		Insets i = getInsets();
		int valTop = rect.y - 2*i.top + scrollBar.getMinimum();  // FIXME why two times the inset?
		int valBottom = valTop + rect.height;
		int val = scrollBar.getValue();

		// Is the rectangle visible with the present scroll bar position
		if (val <= valTop && valBottom <= val + scrollBar.getVisibleAmount())
			return;

		// Show the rectangle at the top of the view area
		scrollBar.setValue(valTop);
	}

	protected static class ScrollableMenuLayout implements LayoutManager{

		private static JScrollBar getScrollBar(Container parent) {
			for (Component comp : parent.getComponents()) {
				if (comp.isVisible() && comp instanceof JScrollBar) {
					return (JScrollBar)comp;
				}
			}
			return null;
		}

		private static Dimension getSize(Container parent) {
			Dimension ret = new Dimension();
			for (Component comp : parent.getComponents()) {
				if (!comp.isVisible() || comp instanceof JScrollBar)
					continue;
				ret.width = Math.max(ret.width, comp.getPreferredSize().width);
				ret.height += comp.getPreferredSize().height;
			}
			return ret;
		}

		private static int getExtent(Container parent, int max) {
			int ret = 0;
			int i = 0;
			for (Component comp : parent.getComponents()) {
				if (!comp.isVisible() || comp instanceof JScrollBar)
					continue;
				if (i >= max)
					break;
				ret += comp.getPreferredSize().height;
				i++;
			}
			return ret;
		}

		private static int getComponentHeight(Container parent) {
			for (Component comp : parent.getComponents()) {
				if (!comp.isVisible() || comp instanceof JScrollBar)
					continue;
				return comp.getPreferredSize().height;
			}
			return 0;
		}

		@Override
		public void addLayoutComponent(String name, Component comp) {}

		@Override
		public void removeLayoutComponent(Component comp) {}

		@Override
		public Dimension preferredLayoutSize(Container parent) {

			// Find the visible portion of the scroll bar
			int visibleAmount = Integer.MAX_VALUE;
			JScrollBar scrollBar = getScrollBar(parent);
			if (scrollBar != null) {
				visibleAmount = scrollBar.getVisibleAmount();
			}

			// Return the adjusted height of the menu
			Dimension ret = getSize(parent);
			Insets insets = parent.getInsets();
			ret.height = Math.min(ret.height + insets.top + insets.bottom, visibleAmount);
			return ret;
		}

		@Override
		public Dimension minimumLayoutSize(Container parent) {
			return preferredLayoutSize(parent);
		}

		@Override
		public void layoutContainer(Container parent) {
			Insets insets = parent.getInsets();

			// Set the bounds for the scroll bar
			JScrollBar scrollBar = getScrollBar(parent);
			int barWidth = 0;
			if (scrollBar != null) {
				barWidth = scrollBar.getPreferredSize().width;
				scrollBar.setBounds(
						parent.getWidth() - insets.right - barWidth,
						insets.top,
						barWidth,
						parent.getHeight() - insets.top - insets.bottom);
			}

			// Set the bounds for the other components
			int y = insets.top;
			if (scrollBar != null) {
				y -= scrollBar.getValue();
			}
			for (Component comp : parent.getComponents()) {
				if (!comp.isVisible() || comp instanceof JScrollBar)
					continue;
				comp.setBounds(
						insets.left,
						y,
						parent.getWidth() - insets.left - insets.right - barWidth,
						comp.getPreferredSize().height);
				y += comp.getPreferredSize().height;
			}
		}
	}

}
