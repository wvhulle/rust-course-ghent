//! Create your own smart pointer
//!

use core::{
    alloc::Layout,
    marker::PhantomData,
    sync::atomic::{AtomicUsize, Ordering},
};
use std::alloc::{alloc, dealloc};

struct Rc<T> {
    address: *const T,
    reference_count: *mut AtomicUsize,
    _type: PhantomData<T>,
}

impl<T> Rc<T> {
    fn new(t: T) -> Self {
        unsafe {
            let data_layout = Layout::new::<T>();
            let data_ptr = alloc(data_layout) as *mut T;
            data_ptr.write(t);

            let count_layout = Layout::new::<AtomicUsize>();
            let count_ptr = alloc(count_layout) as *mut AtomicUsize;
            count_ptr.write(AtomicUsize::new(1));

            Self {
                address: data_ptr,
                reference_count: count_ptr,
                _type: PhantomData,
            }
        }
    }
}

impl<T> Clone for Rc<T> {
    fn clone(&self) -> Self {
        unsafe {
            (*self.reference_count).fetch_add(1, core::sync::atomic::Ordering::AcqRel);
        }
        Self {
            address: self.address,
            reference_count: self.reference_count,
            _type: self._type,
        }
    }
}

impl<T> Drop for Rc<T> {
    fn drop(&mut self) {
        unsafe {
            if (*self.reference_count).load(core::sync::atomic::Ordering::Acquire) == 1 {
                dealloc(self.address as *mut u8, Layout::new::<T>());
                dealloc(self.reference_count as *mut u8, Layout::new::<T>())
            } else {
                (*self.reference_count).fetch_sub(1, core::sync::atomic::Ordering::AcqRel);
            }
        }
    }
}

fn main() {
    let t = "test";
    let rc = Rc::new(t);
    let count_mut = unsafe { rc.reference_count };
    dbg!(count_mut);
    let value = unsafe { (*count_mut).load(Ordering::Relaxed) };
    dbg!(value);
    let count = unsafe { (*(rc.reference_count)).load(Ordering::Relaxed) };
    dbg!(count);
    assert_eq!(count, 1);

    let clone = rc.clone();

    let count = unsafe { (*(clone.reference_count)).load(Ordering::Relaxed) };
    dbg!(count);

    drop(clone);

    let count = unsafe { (*(rc.reference_count)).load(Ordering::Relaxed) };
    dbg!(count);

    drop(rc);

    let count = unsafe { (*count_mut).load(Ordering::Relaxed) };
    dbg!(count);
}
