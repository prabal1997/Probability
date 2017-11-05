//SAMPLE BASH INPUT: 'g++ sim.cpp -lpthread -std=c++11'

#include<iostream>
#include<random>
#include<chrono>
#include<sys/types.h>
#include<cstdio>
#include<unistd.h>
#include<cmath>
#include<iomanip>
#include<pthread.h>
#include<vector>

//parameters
const long double service_mean(0.2);
const int arrival_rate(10);
const long double ideal_average(arrival_rate*service_mean);
const int chunk_size(400);
const int required_prec(0.01); //this refers to the fact that a precision of 1% is required

const long double ARRAY_READ_TIME = 0;
const long double VARIABLE_WRITE_TIME = 0;

long double current_average(0);
int alive_threads(chunk_size); //this is modified by dying threads

//global resources
enum CODES {NORMAL, ERROR, ACHIEVED};
pthread_mutex_t mutex_lock;
bool global_thread_alive[chunk_size] = {false};
int thread_alive_samples[chunk_size] = {0};

//function pre-declarations
void spawn_thread();
long double service_inv_dist(long double, long double);
long double arrival_inv_dist(long double, long double);
void* thread_work(void*);
void sleep_for(long double);

int main() {
        //record keeper for running averages
        std::vector<long double> running_average_keeper;
     
        //set precision properly
        std::cout << std::fixed;
        std::cout << std::setprecision(9);
        
        //random number generator
        std::random_device r_device;
        std::mt19937 generate(r_device());
        std::uniform_real_distribution<> uni_dis(0.0, 1.0);

        long double prec_measure(0);
        int chunk_counter = 0;
        while(true) {
                //we restart the simulation after each iteration
                alive_threads = chunk_size;
                
                //create thread IDs, attributes
                pthread_t* thread_ids = new pthread_t[chunk_size];
                pthread_attr_t* thread_attrs = new pthread_attr_t[chunk_size];
                
                //make each thread 'alive', delay them appropriately
                for (uint64_t thread_count = 1; thread_count <= chunk_size; ++thread_count) {
                        //generate arrival, service time in seconds
                        long double arrival_time(arrival_inv_dist(1.0/arrival_rate, uni_dis(generate) ));
                        long double service_time(service_inv_dist(service_mean, uni_dis(generate) ));
                        void* data_array[3] = {&arrival_time, &service_time, (void*)thread_count};

                        //count number of alive threads
                        thread_alive_samples[thread_count-1] = 0;
                        for (int counter = 0; counter < thread_count; ++counter)
                             thread_alive_samples[thread_count-1] += (int)global_thread_alive[counter];

                        //spawn a new thread (after appropriate delay)
                        pthread_attr_init(&thread_attrs[thread_count-1]);
                        pthread_create(&thread_ids[thread_count-1], &thread_attrs[thread_count-1], thread_work, data_array);
                }
                //wait for all threads to die out
                if (alive_threads==0)
                    std::cout << "YO DONE!";
                
                
               //increment the number of chunks used
               ++chunk_counter;
    
                //calculate TOTAL average, store in VECTOR
                long double sampled_sum = 0;
                for (int counter = 0; counter < chunk_size; ++counter)
                    sampled_sum += thread_alive_samples[counter];
                
                long double temp_current_average = sampled_sum*1.0/chunk_size;
                current_average = (current_average*(chunk_counter-1) + temp_current_average)/chunk_counter;
                running_average_keeper.push_back(current_average);
                
                //check if termination is required
                long double calc_prec = (current_average-ideal_average)/ideal_average;
                if ( (calc_prec < required_prec) && (calc_prec > -required_prec) ) {
                     std::cout << "SUCCESS: precision OF " << (1-fabs(calc_prec))*100 << " percent achieved!.\n";
                     break;
                }
                else {
                     //std::cout << "INCOMPLETE: precision OF " << (1-fabs(calc_prec))*100 << " percent achieved at " << current_average << " avg.\n";
                     std::cout << "INCOMPLETE: local avg OF " << temp_current_average << " achieved at total " << current_average << " avg.\n";
                }
                
                //deallocate memory
                delete[] thread_ids;
                delete[] thread_attrs;
                
                std::cout << "REPEAT: iteration " << chunk_counter + 1 << " starts.\n";
        }
        
        //write out the running average output to a text-file
        

        return ACHIEVED;
}

void spawn_thread() {
}

long double service_inv_dist(long double mean, long double uni_rand_val) {
        return -mean*log(1-uni_rand_val)*(uni_rand_val >= 0)*(uni_rand_val < 1);
}

long double arrival_inv_dist(long double mean, long double uni_rand_val) {
        return mean*(uni_rand_val >= 0)*(uni_rand_val < 1);
}

//function sleeps as precisely as possible to the given input seconds
void* thread_work(void* input_data) {
     //get info
     long double arrival_wait = *((long double*)((void**)input_data)[0]);
     long double duration = *((long double*)((void**)input_data)[1]);
     uint64_t thread_num = (uint64_t)(((void**)input_data)[2]);
     
     //sleep for the given time
     sleep_for(arrival_wait);
     global_thread_alive[thread_num-1] = true;

     sleep_for(duration);
     global_thread_alive[thread_num-1] = false;
     
     //decrement thread counter
     pthread_mutex_lock(&mutex_lock);
     alive_threads -= 1;
     pthread_mutex_unlock(&mutex_lock);
     
     pthread_exit(nullptr);
}

//function causes thread to fall asleep for some time
void sleep_for(long double sleep_time) {
     const int NANO_CONV = 1000000000;
     sleep_time = sleep_time*NANO_CONV;
     
     bool sleep = true;
     auto start = std::chrono::high_resolution_clock::now();
     while(sleep)      {
         auto now = std::chrono::high_resolution_clock::now();
         auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(now - start);
         if ( elapsed.count() > sleep_time )
             sleep = false;
     }
}